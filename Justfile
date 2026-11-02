# Builds, diffs, activation and store hygiene go through `nh`; it renders the
# build plan with nix-output-monitor and prints the closure diff itself.
# Each recipe keeps the native command it wraps as a comment for reference.

default:
    @just --list

check:
    nix flake check --no-update-lock-file --no-write-lock-file

# List what a build would compile locally instead of substituting.
audit-build:
    @nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link --dry-run --accept-flake-config 2>&1 | sed -n -e 's/^these \([0-9]*\) derivations will be built:/\1 derivations will be built locally:/p' -e 's|^  /nix/store/[a-z0-9]*-\(.*\)\.drv$|  \1|p'

# Advisory checks; neither command rewrites source.
lint:
    deadnix --fail flake.nix hosts modules
    statix check . --ignore '.beads/**'

fmt:
    find flake.nix hosts modules flake -type f -name '*.nix' ! -name hardware-configuration.nix ! -name per-device.nix -exec nix fmt -- {} +

# nh has no update subcommand; keep native.
update *inputs:
    nix flake update {{ inputs }}

# ── Build and diff (no activation) ──────────────────────────────────────────

build-thinkpad-x13:
    nh os build . -H thinkpad-x13
    # native: nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link

# Build and show the closure diff without activating.
diff-thinkpad-x13:
    nh os switch --dry . -H thinkpad-x13
    # native: nix store diff-closures /run/current-system "$(nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link --print-out-paths)"

build-macpro-m4:
    nh darwin build . -H macpro-m4
    # native: nix build .#darwinConfigurations.macpro-m4.system --no-link

# Build and show the closure diff without activating.
diff-macpro-m4:
    nh darwin switch --dry . -H macpro-m4
    # native: nix store diff-closures /nix/var/nix/profiles/system "$(nix build .#darwinConfigurations.macpro-m4.system --no-link --print-out-paths)"

build-linux-lab:
    nh home build . -c linux-lab
    # native: nix build .#homeConfigurations.linux-lab.activationPackage --no-link

build-wsl-lab:
    nh home build . -c wsl-lab
    # native: nix build .#homeConfigurations.wsl-lab.activationPackage --no-link

# ── Homelab server (fresh install: direct installer or nixos-anywhere) ──────

build-homelab-x456urk:
    nh os build . -H homelab-x456urk
    # native: nix build .#nixosConfigurations.homelab-x456urk.config.system.build.toplevel --no-link

# Owner-only, destructive: formats and mounts both homelab disks. Run this
# from the target installer, then create secrets and run nixos-install as
# documented in docs/homelab.md.
disko-homelab-x456urk:
    test "$(id -u)" = "0"
    nix run .#disko -- --mode destroy,format,mount hosts/nixos/homelab-x456urk/disko.nix

# Owner-only alternative: destroys the declared disks and installs over SSH
# from another machine. TARGET is user@host of the running installer.
install-homelab-x456urk TARGET:
    test -n "{{ TARGET }}"
    nix run .#nixos-anywhere -- --flake .#homelab-x456urk {{ TARGET }}
    # native: nixos-anywhere --flake .#homelab-x456urk user@host

# Owner-only, destructive: mounts the declared ThinkPad layout so a fresh
# install can be performed. See docs/homelab.md for the full reinstall steps.
disko-thinkpad-x13:
    test "$(id -u)" = "0"
    nix run .#disko -- --mode destroy,format,mount hosts/nixos/thinkpad-x13/disko.nix

# ── Activation (owner-only; agents never run these) ─────────────────────────

# Activate on the next boot, leaving the running system untouched.
boot-thinkpad-x13:
    test -e /etc/NIXOS
    test "$(hostname)" = thinkpad-x13
    nh os boot . -H thinkpad-x13
    # native: sudo nixos-rebuild boot --flake .#thinkpad-x13

apply-thinkpad-x13:
    test -e /etc/NIXOS
    test "$(hostname)" = thinkpad-x13
    nh os switch . -H thinkpad-x13
    # native: sudo nixos-rebuild switch --flake .#thinkpad-x13

apply-macpro-m4:
    test "$(uname -s)" = Darwin
    test "$(id -un)" = atalariq
    nh darwin switch . -H macpro-m4
    # native: sudo darwin-rebuild switch --flake .#macpro-m4

apply-linux-lab:
    test "$(uname -s)" = Linux
    test "$(id -un)" = atalariq
    nh home switch . -c linux-lab
    # native: nix run .#home-manager -- switch --flake .#linux-lab

apply-wsl-lab:
    test "$(uname -s)" = Linux
    test "$(id -un)" = atalariq
    nh home switch . -c wsl-lab
    # native: nix run .#home-manager -- switch --flake .#wsl-lab

# ── Store hygiene ───────────────────────────────────────────────────────────

# Keep 14 days and the 5 newest generations; everything older is collectable.
gc:
    nh clean all --keep-since 14d --keep 5
    # native: sudo nix-collect-garbage --delete-older-than 14d

# Nuclear: drop every old generation (rollback history is gone).
gc-all:
    nh clean all
    # native: sudo nix-collect-garbage -d

# nh has no optimise equivalent; keep native.
optimise:
    sudo nix-store --optimise
