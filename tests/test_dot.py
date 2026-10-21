"""Acceptance tests use disposable checkouts/homes and the public CLI boundary."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DotAcceptance(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='dot acceptance ')
        self.addCleanup(self.tmp.cleanup)
        base = Path(self.tmp.name)
        self.repo = base / 'checkout with spaces'
        self.repo.mkdir()
        for folder in ('apps', 'bootstrap'):
            shutil.copytree(ROOT / folder, self.repo / folder, ignore=shutil.ignore_patterns('__pycache__'))
        shutil.copy2(ROOT / 'dot', self.repo / 'dot')
        for folder in ('nix', 'hosts', 'devshells'):
            (self.repo / folder).mkdir()
        for name in ('flake.nix', 'flake.lock'):
            shutil.copy2(ROOT / name, self.repo / name)
        self.home = base / 'home'
        self.home.mkdir()
        self.config = self.home / 'custom config'
        self.bin = base / 'bin'
        self.bin.mkdir()
        (self.bin / 'python3').symlink_to(sys.executable)
        (self.bin / 'dirname').symlink_to(shutil.which('dirname'))
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.config),
                        PATH=str(self.bin), PYTHONDONTWRITEBYTECODE='1')
        self.target = self.config / 'fish/config.fish'

    def cli(self, *args, ok=True, input=None):
        result = subprocess.run([str(self.repo / 'dot'), *args, '--host', 'unknown'],
                                env=self.env, text=True, capture_output=True, input=input)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def apply(self, *extra):
        return self.cli('apply', '--config-only', '--app', 'fish', *extra)

    def manifest(self, change):
        path = self.repo / 'apps/manifest.json'
        data = json.loads(path.read_text())
        change(data)
        path.write_text(json.dumps(data))

    def snapshot(self):
        return sorted((str(p.relative_to(self.home)), p.lstat().st_mtime_ns,
                       os.readlink(p) if p.is_symlink() else p.read_bytes() if p.is_file() else None)
                      for p in self.home.rglob('*'))

    def test_nix_free_idempotence_direct_edit_spaces_and_custom_root(self):
        self.assertIsNone(shutil.which('nix', path=self.env['PATH']))
        self.apply()
        first = self.target.lstat().st_mtime_ns
        self.apply()
        self.assertEqual(first, self.target.lstat().st_mtime_ns)
        self.target.write_text('# edited through deployed path\n')
        self.assertEqual((self.repo / 'apps/fish/config.fish').read_text(), '# edited through deployed path\n')

    def test_conflicts_preserved_and_preflight_is_complete(self):
        self.target.parent.mkdir(parents=True)
        self.target.write_text('personal config')
        before = self.snapshot()
        self.cli('apply', '--config-only', ok=False)
        self.assertEqual(before, self.snapshot())

    def test_backup_never_overwrites_old_backups(self):
        self.target.parent.mkdir(parents=True)
        self.target.write_text('first')
        self.apply('--backup')
        self.target.unlink()
        self.target.write_text('second')
        self.apply('--backup')
        saved = list(self.target.parent.glob('config.fish.dot-backup-*'))
        self.assertEqual({p.read_text() for p in saved}, {'first', 'second'})

    def test_foreign_and_broken_symlink_preserved(self):
        self.target.parent.mkdir(parents=True)
        foreign = self.home / 'foreign'
        for exists in (True, False):
            if exists:
                foreign.write_text('foreign')
            else:
                foreign.unlink()
            self.target.symlink_to(foreign)
            self.cli('apply', '--config-only', '--app', 'fish', ok=False)
            self.assertEqual(os.readlink(self.target), str(foreign))
            self.apply('--backup')
            self.assertTrue(self.target.is_symlink())
            self.target.unlink()

    def test_ancestor_symlink_rejected_even_with_backup(self):
        self.config.mkdir()
        foreign = self.home / 'elsewhere'
        foreign.mkdir()
        (self.config / 'fish').symlink_to(foreign)
        self.cli('apply', '--config-only', '--app', 'fish', '--backup', ok=False)
        self.assertEqual(list(foreign.iterdir()), [])

    def test_local_override_preserved(self):
        self.target.parent.mkdir(parents=True)
        local = self.target.with_name('config.local.fish')
        local.write_text('set -g local_test yes\n')
        self.apply()
        self.assertEqual(local.read_text(), 'set -g local_test yes\n')

    def test_plan_doctor_are_read_only(self):
        self.apply()
        before = self.snapshot()
        self.cli('plan', '--config-only')
        self.cli('doctor', '--config-only', ok=False)  # required binaries are absent
        self.assertEqual(before, self.snapshot())

    def test_invalid_manifest_fails_before_linking(self):
        for change in (
            lambda d: d['apps']['fish']['links'][0].update(target='../outside'),
            lambda d: d['apps']['fish']['links'][0].update(source='apps/fish/missing'),
            lambda d: d['apps']['fish']['links'][0].update(source='apps/nvim/init.lua'),
            lambda d: d['apps']['bat']['links'][0].update(target='fish'),
            lambda d: d['apps'].update({'bad/id': d['apps']['fish']}),
        ):
            shutil.copy2(ROOT / 'apps/manifest.json', self.repo / 'apps/manifest.json')
            self.manifest(change)
            self.cli('apply', '--config-only', ok=False)
            self.assertFalse(self.config.exists())

    def test_symlinked_source_rejected(self):
        source = self.repo / 'apps/fish/config.fish'
        source.unlink()
        source.symlink_to('/etc/passwd')
        self.cli('apply', '--config-only', ok=False)
        self.assertFalse(self.config.exists())

    def test_application_scoped_full_apply_rejected(self):
        result = self.cli('apply', '--app', 'fish', ok=False)
        self.assertIn('--config-only', result.stderr)

    def test_removed_app_reports_exact_stale_link(self):
        self.apply()
        self.manifest(lambda d: d['baseline'].remove('fish'))
        result = self.cli('plan', '--config-only')
        self.assertIn(f'STALE/UNSELECTED: {self.target}', result.stdout)
        self.assertTrue(self.target.is_symlink())

    def test_copied_fish_folder_starts_with_optional_tools_absent(self):
        fish = shutil.which('fish')
        if not fish:
            self.skipTest('Fish unavailable')
        shutil.copytree(self.repo / 'apps/fish', self.config / 'fish')
        (self.config / 'fish/config.local.fish').write_text('set -g local_loaded yes\n')
        result = subprocess.run([fish, '-i', '-c', 'test "$local_loaded" = yes'], env=self.env,
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('Unknown command', result.stderr)

    def hm(self, mode):
        options = self.home / 'hm-options.json'
        options.write_text(json.dumps(dict(checkout=str(self.repo), home=str(self.home),
                          config=str(self.config), selected=['fish'],
                          manifest=str(self.repo / 'apps/manifest.json'))))
        return subprocess.run([sys.executable, '-B', str(self.repo / 'bootstrap/hm-links.py'),
                               mode, str(options)], env=self.env, text=True, capture_output=True)

    def test_hm_helper_and_config_only_interoperate(self):
        self.apply()
        self.assertEqual(self.hm('check').returncode, 0)
        self.assertEqual(self.hm('apply').returncode, 0)
        self.apply()
        self.assertEqual(self.target.resolve(), self.repo / 'apps/fish/config.fish')

    def test_hm_preflight_preserves_identical_foreign_file(self):
        self.target.parent.mkdir(parents=True)
        shutil.copy2(self.repo / 'apps/fish/config.fish', self.target)
        self.assertNotEqual(self.hm('check').returncode, 0)
        self.assertFalse(self.target.is_symlink())

    def test_interrupted_apply_reports_partial_progress(self):
        blocked = self.config / 'yazi'
        blocked.mkdir(parents=True)
        blocked.chmod(0o500)
        try:
            result = self.cli('apply', '--config-only', '--app', 'fish', '--app', 'yazi', ok=False)
            self.assertIn('PARTIAL APPLY', result.stderr)
            self.assertTrue(self.target.is_symlink())
            self.assertFalse((blocked / 'yazi.toml').exists())
        finally:
            blocked.chmod(0o700)
        self.cli('apply', '--config-only', '--app', 'fish', '--app', 'yazi')

    def test_store_intermediary_link_is_owned(self):
        self.target.parent.mkdir(parents=True)
        intermediary = self.home / 'intermediary'
        intermediary.symlink_to(self.repo / 'apps/fish/config.fish')
        self.target.symlink_to(intermediary)
        self.apply()
        self.assertEqual(os.readlink(self.target), str(intermediary))

    def fake_nix(self, fail=False):
        log = self.home / 'nix-calls'
        # A real immutable directory solely to satisfy output validation. No activation runs.
        store = Path(sys.executable).resolve().parents[1]
        if not str(store).startswith('/nix/store/'):
            self.skipTest('Nix store unavailable for orchestration fixture')
        script = self.bin / 'nix'
        script.write_text(f'#!{sys.executable}\nimport sys\n'
                          f'with open({str(log)!r}, "a") as f: f.write(repr(sys.argv)+"\\n")\n'
                          + ('sys.exit(1)\n' if fail else f'print({str(store)!r})\n'))
        script.chmod(0o755)
        return log

    def test_build_failure_does_not_activate(self):
        log = self.fake_nix(fail=True)
        before = self.snapshot()
        self.cli('apply', ok=False, input='activate unknown\n')
        self.assertEqual(len(log.read_text().splitlines()), 1)
        self.assertFalse(self.config.exists())

    def test_refusal_does_not_activate_and_apply_does_not_update_pins(self):
        log = self.fake_nix()
        result = self.cli('apply', input='no\n')
        self.assertIn('Activation refused', result.stdout)
        calls = log.read_text()
        self.assertIn('--no-update-lock-file', calls)
        self.assertNotIn("'update'", calls)
        self.assertFalse(self.config.exists())

    def test_system_activation_refusal(self):
        host = self.repo / 'hosts/unknown'
        host.mkdir()
        (host / 'host.json').write_text(json.dumps(dict(integration='nixos',
            checkout=str(self.repo), homeDirectory=str(self.home))))
        self.env.pop('XDG_CONFIG_HOME')
        log = self.fake_nix()
        result = self.cli('apply', input='no\n')
        self.assertIn('Activation refused', result.stdout)
        self.assertIn('NixOS system + Home Manager', result.stdout)
        self.assertNotIn('switch-to-configuration', log.read_text())
        self.assertFalse((self.home / '.config').exists())


if __name__ == '__main__':
    unittest.main()
