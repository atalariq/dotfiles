#!/usr/bin/env python3
"""Thin Nix orchestration and conservative, standard-library native linking."""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import platform
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import uuid


class Invalid(ValueError):
    pass


def read_json(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError) as exc:
        raise Invalid(f"Cannot read {path}: {exc}") from exc


def relative(value):
    if not isinstance(value, str) or not value or '\\' in value:
        raise Invalid(f"Invalid relative path: {value!r}")
    path = PurePosixPath(value)
    if path.is_absolute() or any(p in ('', '.', '..') for p in value.split('/')):
        raise Invalid(f"Unsafe relative path: {value!r}")
    return path


def absolute(value):
    path = Path(value).expanduser()
    if not path.is_absolute() or '..' in path.parts:
        raise Invalid(f"Expected absolute path: {value}")
    return path


def no_symlink_ancestors(path):
    for parent in reversed(path.parents):
        if parent.is_symlink():
            raise Invalid(f"Symlinked ancestor: {parent}; migrate this directory explicitly first")
        if parent.exists() and not parent.is_dir():
            raise Invalid(f"Non-directory ancestor: {parent}")


def owned(target, source):
    try:
        return target.is_symlink() and target.resolve(strict=True) == source.resolve(strict=True)
    except (OSError, RuntimeError):
        return False


def status(target, source):
    if owned(target, source):
        return 'owned'
    return 'conflict' if os.path.lexists(target) else 'missing'


def mappings(repo, manifest, home, config, selected, check_targets=True):
    if not isinstance(manifest, dict) or manifest.get('version') != 1 or not isinstance(manifest.get('apps'), dict):
        raise Invalid('Expected manifest version 1 and an apps object')
    apps = manifest['apps']
    baseline = manifest.get('baseline')
    if not isinstance(baseline, list) or any(a not in apps for a in baseline):
        raise Invalid('Invalid baseline application IDs')
    if any(a not in apps for a in selected):
        raise Invalid('Unknown application ID in selection')
    result, targets = [], []
    for app, data in apps.items():
        if not re.fullmatch(r'[a-z][a-z0-9-]*', app) or not isinstance(data, dict):
            raise Invalid(f'Invalid app ID or record: {app}')
        for key in ('packages', 'commands', 'links'):
            if not isinstance(data.get(key), list):
                raise Invalid(f'{app}: {key} must be a list')
        if any(not isinstance(p, str) or not re.fullmatch(r'[a-zA-Z0-9_+-]+', p)
               for p in data['packages'] + data['commands']):
            raise Invalid(f'{app}: invalid package or command')
        for link in data['links']:
            src = relative(link['source'])
            if src.parts[:2] != ('apps', app):
                raise Invalid(f'{app}: source must be inside apps/{app}')
            source = repo / str(src)
            no_symlink_ancestors(source)
            if source.is_symlink() or not source.exists():
                raise Invalid(f'Missing or symlinked source: {source}')
            if not source.resolve().is_relative_to(repo):
                raise Invalid(f'Source escapes checkout: {source}')
            kind = link['kind']
            if kind not in ('file', 'directory') or not (source.is_file() if kind == 'file' else source.is_dir()):
                raise Invalid(f'Wrong source kind: {source}')
            if kind == 'directory' and any(p.is_symlink() for p in source.rglob('*')):
                raise Invalid(f'Symlinks inside config-only directory: {source}')
            root = {'home': home, 'config': config}.get(link['root'])
            if root is None:
                raise Invalid('Target root must be home or config')
            target = root / str(relative(link['target']))
            for previous in targets:
                if target == previous or target in previous.parents or previous in target.parents:
                    raise Invalid(f'Overlapping targets: {previous} and {target}')
            targets.append(target)
            if app in selected:
                if check_targets:
                    no_symlink_ancestors(target)
                result.append((app, source, target))
    return result


def select_host(repo, name):
    name = name or socket.gethostname().split('.')[0]
    if not re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9_-]*', name):
        raise Invalid('Invalid host name')
    path = repo / 'hosts' / name / 'host.json'
    local = path.with_name('host.local.json')
    host = read_json(local if local.exists() else path) if path.exists() else {}
    if not isinstance(host, dict) or host.get('integration') not in (None, 'standalone', 'nixos'):
        raise Invalid('Host integration must be standalone or nixos; other system adapters are not implemented')
    return name, host


def selected_apps(manifest, host, requested):
    chosen = requested or list(dict.fromkeys(manifest['baseline'] + host.get('include', [])))
    return [a for a in chosen if a not in host.get('exclude', [])] if not requested else chosen


def state_path(home):
    # Deliberately home-relative; custom config roots share one ownership ledger.
    return home / '.local/state/dotfiles/links.json'


def stale_links(home, links):
    path = state_path(home)
    no_symlink_ancestors(path)
    if path.is_symlink():
        raise Invalid(f'Symlinked ownership ledger: {path}')
    old = read_json(path) if path.exists() else {}
    if not isinstance(old, dict):
        raise Invalid('Invalid ownership ledger')
    current = {str(t) for _, _, t in links}
    for target, source in old.items():
        if target not in current and os.path.lexists(target):
            print(f'STALE/UNSELECTED: {target} (recorded source: {source}); '
                  'retained. If retiring this mapping, inspect readlink and remove only that symlink.')
    return old


def link_configs(home, links, backup):
    old = stale_links(home, links)
    conflicts = [t for _, s, t in links if status(t, s) == 'conflict']
    if conflicts and not backup:
        raise Invalid('Conflicts preserved: ' + ', '.join(map(str, conflicts)) +
                      '; inspect them, then explicitly use --backup to replace')
    completed = []
    try:
        for _, source, target in links:
            no_symlink_ancestors(target)
            if owned(target, source):
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            if os.path.lexists(target):
                if not backup:
                    raise Invalid(f'New conflict appeared: {target}')
                saved = target.with_name(target.name + '.dot-backup-' + uuid.uuid4().hex)
                target.rename(saved)
                print(f'BACKUP: {target} -> {saved}', flush=True)
            # symlink() fails on a concurrently created destination; never overwrite it.
            target.symlink_to(source, target_is_directory=source.is_dir())
            completed.append(str(target))
            print(f'LINKED: {target}', flush=True)
        old.update({str(t): str(s) for _, s, t in links})
        ledger = state_path(home)
        ledger.parent.mkdir(parents=True, exist_ok=True)
        fd, temporary = tempfile.mkstemp(prefix='.links-', dir=ledger.parent)
        with os.fdopen(fd, 'w') as stream:
            json.dump(old, stream, indent=2)
        os.replace(temporary, ledger)
    except (OSError, Invalid, KeyboardInterrupt):
        print('PARTIAL APPLY: completed links: ' + repr(completed) +
              '. Preserve printed backups; fix the error and rerun. No automatic rollback.', file=sys.stderr)
        raise


def run(command, **kwargs):
    return subprocess.run(command, check=True, text=True, **kwargs)


def nix_string(value):
    return json.dumps(str(value)).replace('${', r'\${')


def snapshot(repo, destination):
    """Only public v1 sources enter the Nix store, never legacy configs or local overrides."""
    ignored = shutil.ignore_patterns('*.local.*', '*.private.*', '__pycache__', '*.pyc',
                                     '*.dot-backup-*', '.git')
    for folder in ('apps', 'bootstrap', 'nix', 'hosts', 'devshells'):
        shutil.copytree(repo / folder, destination / folder, ignore=ignored, symlinks=True)
    for filename in ('flake.nix', 'flake.lock'):
        shutil.copy2(repo / filename, destination / filename)
    # A host override is an explicit public Nix input; never use it for secrets.
    for path in (repo / 'hosts').glob('*/host.local.json'):
        shutil.copy2(path, destination / 'hosts' / path.parent.name / 'host.json')


def build(repo, name, host, home, config):
    if not shutil.which('nix'):
        raise Invalid('Nix is absent. Use --config-only, or explicitly install Nix yourself first.')
    with tempfile.TemporaryDirectory(prefix='dot-source-') as temporary:
        source = Path(temporary)
        snapshot(repo, source)
        return build_snapshot(source, repo, name, host, home, config)


def build_snapshot(source, repo, name, host, home, config):
    flags = ['--no-update-lock-file', '--no-write-lock-file']
    if host.get('integration') == 'nixos':
        if str(repo) != host['checkout'] or str(home) != host['homeDirectory']:
            raise Invalid('Host checkout/home mismatch; update host.local.json before building')
        if config != home / '.config':
            raise Invalid('NixOS host uses its declared config root; custom roots are config-only')
        command = ['nix', 'build', f'path:{source}#nixosConfigurations.{name}.config.system.build.toplevel']
    else:
        arch = {'arm64': 'aarch64', 'aarch64': 'aarch64', 'x86_64': 'x86_64'}.get(platform.machine())
        if not arch or sys.platform not in ('linux', 'darwin'):
            raise Invalid('Supported systems: x86_64/aarch64 Linux and macOS; WSL uses Linux')
        if sys.platform == 'darwin' and arch == 'x86_64':
            raise Invalid('Pinned Nixpkgs 26.11 dropped Intel macOS. Use --config-only on Intel Macs; '
                          'Apple Silicon supports the pinned Home Manager path.')
        args = dict(host, username=home.name, homeDirectory=str(home), checkout=str(repo),
                    configHome=str(config), system=f'{arch}-{"darwin" if sys.platform == "darwin" else "linux"}')
        # Explicit runtime identity in a small JSON argument, not implicit Nix environment reads.
        import getpass
        args['username'] = host.get('username', getpass.getuser())
        expression = (f'let f = builtins.getFlake {nix_string("path:" + str(source))}; '
                      f'in (f.lib.mkHome (builtins.fromJSON {nix_string(json.dumps(args))})).activationPackage')
        command = ['nix', 'build', '--impure', '--expr', expression]
    # Keep build diagnostics live; only stdout is machine-readable output paths.
    result = run(command + flags + ['--no-link', '--print-out-paths'], stdout=subprocess.PIPE)
    output = result.stdout.strip().splitlines()[-1]
    if not output.startswith('/nix/store/') or not Path(output).is_dir():
        raise Invalid(f'Unexpected build output: {output}')
    print(f'BUILT: {output}')
    return Path(output)


def activate(output, host, name):
    system = host.get('integration') == 'nixos'
    print(f'Ready to activate {"NixOS system + home" if system else "user home"}: {output}')
    if system and Path('/run/current-system').exists():
        run(['nix', 'store', 'diff-closures', '/run/current-system', str(output)])
    try:
        answer = input(f'Type "activate {name}" to approve this built output (anything else refuses): ')
    except EOFError:
        answer = ''
    if answer != f'activate {name}':
        print('Activation refused; active system/home unchanged. Build output remains in the Nix store.')
        return
    try:
        if system:
            run(['sudo', 'nix-env', '--profile', '/nix/var/nix/profiles/system', '--set', str(output)])
            run(['sudo', str(output / 'bin/switch-to-configuration'), 'switch'])
        else:
            run([str(output / 'activate')])
    except subprocess.CalledProcessError:
        print('PARTIAL ACTIVATION: inspect logs and current generation. For NixOS, select a previous '
              'boot generation or explicitly rebuild --rollback. For standalone HM, activate the previous '
              'generation. Live configuration content needs Git/manual recovery.', file=sys.stderr)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['plan', 'apply', 'build', 'doctor', 'update'])
    parser.add_argument('--config-only', action='store_true')
    parser.add_argument('--app', action='append')
    parser.add_argument('--backup', action='store_true', help='explicitly back up conflicting mapped objects')
    parser.add_argument('--host')
    parser.add_argument('--home', default=os.environ.get('HOME'))
    parser.add_argument('--config-home', default=os.environ.get('XDG_CONFIG_HOME'))
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    if args.app and not args.config_only:
        raise Invalid('--app is only supported with --config-only; a system rebuild cannot isolate one app')
    if args.backup and (args.command != 'apply' or not args.config_only):
        raise Invalid('--backup is supported only for config-only apply')
    if args.command in ('build', 'update') and args.config_only:
        raise Invalid(f'{args.command} requires Nix; --config-only does not apply')
    if args.command in ('apply', 'update') and hasattr(os, 'geteuid') and os.geteuid() == 0:
        raise Invalid('Run dot as your regular user; only system activation uses sudo')
    home = absolute(args.home)
    config = absolute(args.config_home or str(home / '.config'))
    name, host = select_host(repo, args.host)
    manifest = read_json(repo / 'apps/manifest.json')
    selected = selected_apps(manifest, host, args.app)
    # Validate sources and targets before any mutation or Nix operation.
    links = mappings(repo, manifest, home, config, selected, check_targets=False)
    hazards = {}
    for _, _, target in links:
        try:
            no_symlink_ancestors(target)
        except Invalid as exc:
            hazards[target] = str(exc)
    print(f'Host: {name}; apps: {", ".join(selected)}')
    system = not args.config_only and host.get('integration') == 'nixos'
    print(f'Scope: {"NixOS system + Home Manager" if system else "config-only" if args.config_only else "standalone Home Manager"}')
    for app, source, target in links:
        if target in hazards:
            print(f'BLOCKED: {app}: {hazards[target]}')
        else:
            print(f'{status(target, source).upper()}: {app}: {target} -> {source}')
    if hazards and args.command == 'apply':
        raise Invalid('; '.join(dict.fromkeys(hazards.values())))
    if args.command in ('plan', 'doctor'):
        stale_links(home, links)
        print('Static intent preview; no build closure diff computed.')
        packages = [p for a in selected for p in manifest['apps'][a]['packages']]
        print('Packages: ' + ('none (config-only)' if args.config_only else ', '.join(packages)))
        if args.command == 'doctor':
            missing = [c for a in selected for c in manifest['apps'][a]['commands'] if not shutil.which(c)]
            for command in missing:
                print(f'MISSING COMMAND: {command}')
            if not args.config_only and not shutil.which('nix'):
                missing.append('nix')
                print('MISSING COMMAND: nix')
            return int(bool(missing) or bool(hazards) or any(status(t, s) != 'owned' for _, s, t in links))
    elif args.command == 'update':
        before = (repo / 'flake.lock').read_text()
        with tempfile.TemporaryDirectory(prefix='dot-update-') as temporary:
            source = Path(temporary)
            snapshot(repo, source)
            run(['nix', 'flake', 'update', '--flake', f'path:{source}'])
            shutil.copy2(source / 'flake.lock', repo / 'flake.lock')
        import difflib
        print(''.join(difflib.unified_diff(before.splitlines(True),
              (repo / 'flake.lock').read_text().splitlines(True), fromfile='old lock', tofile='new lock')))
        print('Pins updated; no activation. Application plugins update through their own tooling.')
    elif args.config_only:
        link_configs(home, links, args.backup)
    else:
        if args.command == 'apply' and any(status(t, s) == 'conflict' for _, s, t in links):
            raise Invalid('Conflicts preserved; review plan and migrate files before full apply')
        output = build(repo, name, host, home, config)
        if args.command == 'apply':
            activate(output, host, name)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (Invalid, OSError, KeyError, TypeError, subprocess.CalledProcessError, RuntimeError) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        if isinstance(exc, subprocess.CalledProcessError) and exc.stderr:
            print(exc.stderr, file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print('Interrupted; inspect any completed stages before rerunning.', file=sys.stderr)
        sys.exit(130)
