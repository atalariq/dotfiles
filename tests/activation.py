#!/usr/bin/env python3
"""Exercise real HM activation in a disposable HOME, profile and D-Bus session.

Requires Python, a local Nix daemon and dbus-run-session. No workstation
activation, real-user profile changes, or store-path collection is performed.
"""

import json
import os
import pwd
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    with tempfile.TemporaryDirectory(prefix="dotfiles-theme-") as temporary:
        work = Path(temporary)
        home = work / "home"
        home.mkdir()
        (work / "runtime").mkdir(mode=0o700)
        expression = '''
          let
            root = builtins.getEnv "DOTFILES_TEST_REPO";
            f = builtins.getFlake root;
            pkgs = import f.inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          in (f.inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs.inputs = f.inputs;
            modules = [ (root + "/modules/home-manager") {
              home.username = builtins.getEnv "DOTFILES_TEST_USER";
              home.homeDirectory = ''' + json.dumps(str(home)) + ''';
              home.stateVersion = "26.05";
              xdg.enable = true;
              systemd.user.startServices = false;
              dotfiles.appearance.enable = true;
            } ];
          }).activationPackage
        '''
        build_env = os.environ.copy()
        build_env.update(
            DOTFILES_TEST_REPO=str(ROOT),
            DOTFILES_TEST_USER=pwd.getpwuid(os.getuid()).pw_name,
        )
        built = subprocess.run(
            ["nix", "build", "--impure", "--expr", expression, "--json", "--no-link"],
            cwd=ROOT, env=build_env, capture_output=True, text=True,
        )
        if built.returncode:
            print(built.stderr, flush=True)
            built.check_returncode()
        generation = Path(json.loads(built.stdout)[0]["outputs"]["out"])

        # Isolate the legacy-profile migration paths too, while retaining access
        # to the real daemon for the disposable profile and GC-root registration.
        env = os.environ.copy()
        env.update(
            HOME=str(home),
            XDG_CONFIG_HOME=str(home / ".config"),
            XDG_STATE_HOME=str(home / ".local/state"),
            XDG_DATA_HOME=str(home / ".local/share"),
            XDG_CACHE_HOME=str(home / ".cache"),
            XDG_RUNTIME_DIR=str(work / "runtime"),
            DBUS_SESSION_BUS_ADDRESS="unix:path=" + str(work / "runtime/no-bus"),
            NIX_STATE_DIR=str(work / "nix-state"),
            NIX_REMOTE="unix:///nix/var/nix/daemon-socket/socket",
        )
        dconf = subprocess.check_output(
            ["nix", "eval", "--impure", "--raw", "--expr", '''
              let f = builtins.getFlake (builtins.getEnv "DOTFILES_TEST_REPO");
                  p = import f.inputs.nixpkgs { system = "x86_64-linux"; };
              in p.dconf
            '''],
            cwd=ROOT, env=build_env, text=True,
        ).strip()
        env["XDG_DATA_DIRS"] = dconf + "/share:" + env.get(
            "XDG_DATA_DIRS", "/usr/local/share:/usr/share"
        )
        (home / ".local/state/nix/profiles").mkdir(parents=True)

        def run_session(*command):
            subprocess.run(
                ["dbus-run-session", "--", *map(str, command)],
                env=env, check=True, stdout=subprocess.DEVNULL,
            )

        run_session(generation / "activate")
        state = home / ".local/state/dotfiles/theme"
        current = home / ".config/dotfiles-theme/current"
        assert current.read_text().strip() == "gruvbox-dark"
        for name in ["gruvbox-light", "gruvbox-dark", "gruvbox-light"]:
            run_session(generation / "home-path/bin/dotfiles-theme", "set", name)
            assert current.read_text().strip() == name
            assert (state / "root").resolve() == generation
        run_session(generation / "activate")
        assert current.read_text().strip() == "gruvbox-light", "Saved selection lost"

        # Query roots and closure reachability without collecting store paths.
        roots = subprocess.check_output(
            ["nix-store", "--gc", "--print-roots"], text=True, env=env,
        )
        assert str(state / "root") in roots, "Catalogue has no registered GC root"
        closure = set(subprocess.check_output(
            ["nix-store", "--query", "--requisites", str(state / "root")],
            text=True, env=env,
        ).splitlines())
        for name in ["gruvbox-dark", "gruvbox-light"]:
            assert str((generation / "specialisation" / name).resolve()) in closure
        (state / "selected").write_text("retired-theme\n")
        run_session(generation / "activate")
        assert current.read_text().strip() == "gruvbox-dark"
        print("Real isolated HM activation, selection recovery and GC retention passed.")


if __name__ == "__main__":
    main()
