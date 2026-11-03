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

# ── Secrets and bootstrap ───────────────────────────────────────────────────

# Prepare a checkout: hooks, age directory permissions, tool check, identity map.
bootstrap:
    #!/usr/bin/env bash
    set -euo pipefail
    root="$(git rev-parse --show-toplevel)"
    cd "$root"
    git config core.hooksPath .githooks

    for cmd in git sops age age-keygen; do
      if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'missing required command: %s\n' "$cmd" >&2
        printf 'enter the dev shell with: nix develop\n' >&2
        exit 1
      fi
    done

    age_dir="$HOME/.config/sops/age"
    install -d -m 0700 "$age_dir"
    find "$age_dir" -maxdepth 1 -type f -name '*.txt' -exec chmod 600 {} +

    printf 'age identities in %s:\n' "$age_dir"
    shopt -s nullglob
    for key in "$age_dir"/*.txt; do
      printf '  %-24s %s\n' "$(basename "$key")" "$(age-keygen -y "$key" 2>/dev/null || echo invalid)"
    done

    printf '\nEdit a secret with:  just secrets-edit <file>\n'
    printf 'Check a secret with: just secrets-check <file>\n'
    printf 'Create a host key:   just age-init <host>\n'

# Create a new age identity under the canonical SOPS directory.
age-init NAME:
    #!/usr/bin/env bash
    set -euo pipefail
    name="{{ NAME }}"
    case "$name" in
      *[!a-zA-Z0-9-]*) printf 'invalid identity name: %s\n' "$name" >&2; exit 1 ;;
    esac
    age_dir="$HOME/.config/sops/age"
    key="$age_dir/$name.txt"
    install -d -m 0700 "$age_dir"
    if [ -e "$key" ]; then
      printf 'identity already exists: %s\n' "$key" >&2
      exit 1
    fi
    age-keygen -o "$key"
    chmod 600 "$key"
    printf '\nAdd this recipient to .sops.yaml:\n  %s\n' "$(age-keygen -y "$key")"

# Open an encrypted file with the identity that matches its path.
secrets-edit FILE:
    #!/usr/bin/env bash
    set -euo pipefail
    file="{{ FILE }}"
    case "$file" in
      secrets/homelab-x456urk/*) key="$HOME/.config/sops/age/homelab-x456urk.txt" ;;
      secrets/thinkpad-x13/*)     key="$HOME/.config/sops/age/thinkpad-x13.txt" ;;
      *)                          key="$HOME/.config/sops/age/keys.txt" ;;
    esac
    if [ ! -f "$key" ]; then
      printf 'missing age identity: %s\n' "$key" >&2
      exit 1
    fi
    SOPS_AGE_KEY_FILE="$key" exec sops "$file"

# Decrypt and check a secret file without printing its contents.
secrets-check FILE:
    #!/usr/bin/env bash
    set -euo pipefail
    file="{{ FILE }}"
    case "$file" in
      secrets/homelab-x456urk/*) key="$HOME/.config/sops/age/homelab-x456urk.txt" ;;
      secrets/thinkpad-x13/*)     key="$HOME/.config/sops/age/thinkpad-x13.txt" ;;
      *)                          key="$HOME/.config/sops/age/keys.txt" ;;
    esac
    if [ ! -f "$key" ]; then
      printf 'missing age identity: %s\n' "$key" >&2
      exit 1
    fi
    if ! decrypted="$(SOPS_AGE_KEY_FILE="$key" sops -d "$file")"; then
      printf 'failed to decrypt: %s\n' "$file" >&2
      exit 1
    fi
    if printf '%s' "$decrypted" | grep -q 'CHANGE_ME'; then
      printf 'secret still contains CHANGE_ME: %s\n' "$file" >&2
      exit 1
    fi
    printf 'ok: %s\n' "$file"

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

# Owner-only, destructive: direct-installer bootstrap. Verifies the homelab
# sops file, wipes both disks, seeds the age key, then runs nixos-install.
homelab-bootstrap AGE_KEY:
    #!/usr/bin/env bash
    set -euo pipefail
    age_key="{{ AGE_KEY }}"
    test "$(id -u)" = 0
    test -d /mnt
    test -f "$age_key"
    command -v nixos-install >/dev/null

    root="$(pwd)"
    cd "$root"

    if command -v sops >/dev/null 2>&1; then
      sops_cmd=(sops)
    else
      sops_cmd=(nix shell nixpkgs#sops -c sops)
    fi

    if ! decrypted="$(SOPS_AGE_KEY_FILE="$age_key" "${sops_cmd[@]}" \
      -d secrets/homelab-x456urk/secrets.sops.yaml)"; then
      printf 'cannot decrypt homelab secrets with %s\n' "$age_key" >&2
      exit 1
    fi
    if printf '%s' "$decrypted" | grep -q 'CHANGE_ME'; then
      printf 'homelab secrets still contain CHANGE_ME; fill them first\n' >&2
      exit 1
    fi

    printf 'This will WIPE the SSD and HDD declared in disko.nix.\n'
    read -r -p 'Type WIPE to continue: ' answer
    [ "$answer" = "WIPE" ] || { printf 'aborted\n' >&2; exit 1; }

    nix run .#disko -- --mode destroy,format,mount \
      hosts/nixos/homelab-x456urk/disko.nix

    install -d -m 0700 /mnt/persist/var/lib/sops-nix
    install -m 0600 "$age_key" /mnt/persist/var/lib/sops-nix/key.txt

    nixos-install \
      --flake "path:$root#homelab-x456urk" \
      --root /mnt \
      --no-root-passwd

    printf '\nInstalled. Reboot, then run: sudo tailscale status\n'

# Owner-only alternative: destroys the declared disks and installs over SSH.
# This default path reboots before the age key can be seeded; prefer
# install-homelab-x456urk-staged.
install-homelab-x456urk TARGET:
    test -n "{{ TARGET }}"
    nix run .#nixos-anywhere -- --flake .#homelab-x456urk {{ TARGET }}
    # native: nixos-anywhere --flake .#homelab-x456urk user@host

# Owner-only: install over SSH without rebooting, seed the age key, then reboot.
install-homelab-x456urk-staged TARGET AGE_KEY:
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{ TARGET }}"
    age_key="{{ AGE_KEY }}"
    test -n "$target"
    test -f "$age_key"
    command -v ssh >/dev/null
    command -v scp >/dev/null

    nix run .#nixos-anywhere -- \
      --phases kexec,disko,install \
      --flake .#homelab-x456urk \
      "$target"

    ssh "$target" 'install -d -m 0700 /mnt/persist/var/lib/sops-nix'
    scp "$age_key" "$target:/mnt/persist/var/lib/sops-nix/key.txt"
    ssh "$target" 'chmod 600 /mnt/persist/var/lib/sops-nix/key.txt && reboot'

    printf '\nReboot requested. Reconnect after the target gets its network.\n'

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
