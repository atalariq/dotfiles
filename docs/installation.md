# Installation and recovery

## Add a host

1. Create `hosts/nixos/<name>/default.nix` and use your own generated hardware
   configuration. Keep filesystem UUIDs, encrypted devices and boot settings
   appropriate to the machine.
2. Import `modules/nixos`, then explicitly enable its required features. Copy the
   composition pattern from the ThinkPad, not its device identities.
3. Define the user and a Home Manager composition. Choose features individually;
   use `profiles/portable.nix` as a CLI/editor reference.
4. Register a `nixpkgs.lib.nixosSystem` output in `flake.nix`, integrating the
   pinned Home Manager input and passing `inputs` through its special arguments.
5. Set `home.username`, `home.homeDirectory`, and existing stateVersion values.
   In live mode, also set the checkout option. Add new source files to Git after
   reviewing them so the flake can see them.
6. Evaluate, check and build before switching. Review the resulting service,
   package and HOME ownership changes before applying them.

## Existing HOME files

Home Manager stops on foreign-file conflicts. Preserve this protection. Inspect
built generation `home-files` links and compare their destinations with HOME.
Back up conflicting files and symlinks into a private directory outside Git.

Old directory links sometimes need to be replaced with individually owned files.
This matters for Fish state, application login data, Mango and Kitty generated
themes. Never blanket-force a directory over credentials, sessions or writable
application state. Keep backups and a working generation until runtime checks pass.

The source migration has removed all compatibility links and wrappers. Existing
checkout-backed HOME links were backed up privately and moved to canonical
sources. Review the current generation ownership before activation.

## Apply and roll back

Build the desired system and HM outputs first. On the ThinkPad:

```sh
sudo nixos-rebuild switch --flake .#thinkpad-x13
```

The sole host output is `thinkpad-x13`. Review SSH client entries and network
inventory for the hostname before switching. A hostname change does not require regenerating SSH
host keys or changing encrypted-disk identities.

If necessary, return to the previous system generation:

```sh
sudo nixos-rebuild switch --rollback
```

Keep a bootable generation. Native live edits must be reverted with Git or the
file backup; rollback restores immutable generation contents, not external state.
Do not delete database volumes, application data or working rollback generations
as part of a configuration refactor.

## First use

- Confirm password and fingerprint login/unlock/sudo, keyring, SSH forwarding,
  GPG/pinentry, portals, audio and screenshot/recording.
- Confirm suspend/resume, display scaling, Wi-Fi, Bluetooth and battery behaviour.
- Start Neovim and test completion, LSP, formatting, debugging and previews on
  representative projects. No plugin/parser installation command is needed.
- Verify Steam/controller and each selected game/emulator. Game assets, ROMs,
  BIOS files and account enrollment stay outside the repository.
- Android SDK installation, license acceptance and physical-device authorization
  happen in Studio/the owner's terminal.

### Lerd

Lerd remains independent of the project templates. After activation, verify normal
DNS before and after `lerd install --no-ipv6` and `lerd doctor`. Check `.test` DNS
and services with Lerd running and stopped. Add only the generated public mkcert
CA to the system trust configuration after reviewing it; retain its private key
in user state. Database migrations and project creation remain explicit.

### OmniRoute

The service waits for `~/.local/state/omniroute/image.json`. Pull a chosen release,
inspect its actual immutable digest, and write a private file containing:

```json
{"image":"docker.io/diegosouzapw/omniroute@sha256:<verified digest>"}
```

The existing guard accepts only a verified digest-shaped reference and uses
`--pull=never`. Onboarding, API credentials and route selection remain explicit;
this repository does not enable an automatic paid fallback.

## Runtime acceptance

A successful build establishes buildability. Hardware, account, UI and device
checks require the target host and remain pending until actually observed.
Record results and blockers in the validation artifact; do not convert a checklist
into a claim of successful activation.
