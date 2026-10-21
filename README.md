# Portable dotfiles + ThinkPad NixOS

Native application configs live in `apps/`. Nix pins applications; Home Manager
installs the user environment and links the live checkout. `dot` also deploys
configs on Linux, macOS and WSL without Nix. Python 3.10+ is the bootstrap prerequisite.

```sh
./dot plan                         # static intent, no mutation
./dot doctor                       # read-only diagnostics; nonzero means work remains
./dot build --host thinkpad-nixos   # build only; never activates
./dot apply --config-only --app fish
./dot apply --config-only           # all selected native configs
./dot apply                        # preflight + build + explicit activation confirmation
./dot update                       # explicitly refresh Nix pins; no activation
```

The real laptop has existing config conflicts. Read the
[migration and review procedure](docs/dotfiles-v1.md) before any apply. Building
is safe without resolving deployment conflicts. `--backup` is an explicit
config-only option for mapped objects; symlinked ancestor directories require
separate migration. Do not run the wrapper as root.

- **Portable baseline:** Fish, Neovim, Yazi, eza, bat, zoxide, Starship, fd,
  ripgrep and Git. Native app folders include manual-copy instructions.
- **ThinkPad:** preserved hardware/disk/boot definitions and system stateVersion
  `26.05`; Mango or Niri, Noctalia 5.3.0, authenticated session chooser,
  PipeWire/portals, firmware updates, fingerprint daemon, power profiles,
  compressed swap, Android Studio, KVM access and rootless Podman.
- **Development shells:** PHP 8.4/Composer/Node 22/SQLite for Laravel;
  JDK 17/adb for Android. Project dependencies and SDK downloads remain project
  or user state, outside the global terminal baseline.
- **Portability:** Linux and Apple Silicon hosts can use standalone Home Manager;
  Intel macOS uses config-only because pinned Nixpkgs 26.11 dropped Intel support.
  There is no implicit nix-darwin/non-NixOS system management. Native Windows
  is excluded; WSL is a Linux user environment.

```sh
# From a project directory, once this checkout is committed:
nix develop /path/to/dotfiles#laravel
nix develop /path/to/dotfiles#android
```

`apps/manifest.json` owns mappings and package selection. `hosts/<name>/host.json`
records host identity and `include`/`exclude` differences. An ignored
`host.local.json` replaces that record. Host records are public Nix inputs:
keep secrets elsewhere. Moving the clone requires updating its recorded path
and reapplying. `./dot build` uses a filtered source snapshot so legacy files
and native `*.local.*` overrides are excluded from the Nix store.

[Architecture, approval, recovery and development](docs/dotfiles-v1.md) ·
[Verification results](docs/validation.md) · [Approved specification](docs/migrate-to-nix.spec.md)

The old `config/`, `profiles/`, `script/` and `setup.sh` remain available for
recovery, along with the [legacy guide](docs/legacy-dotfiles.md). They are not
inputs to the new deployment path. Existing local modifications are preserved.
