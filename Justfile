# Builds, diffs, activation and store hygiene go through `nh`; it renders the
# build plan with nix-output-monitor and prints the closure diff itself.
# Each recipe keeps the native command it wraps as a comment for reference.

# A fresh host must accept the flake's nixConfig (binary caches) before the
# first activation has written /etc/nix/nix.conf. Trust is explicit: this
# project's flake.nix only sets extra substituters and their public keys.
export NIX_CONFIG := "accept-flake-config = true"

default:
    @just --list

check:
    nix flake check --no-update-lock-file --no-write-lock-file

# Advisory checks; neither command rewrites source.
lint:
    deadnix --fail flake.nix hosts modules
    statix check . --ignore '.beads/**'

fmt:
    find flake.nix hosts modules flake -type f -name '*.nix' ! -name hardware-configuration.nix ! -name per-device.nix -exec nix fmt -- {} +

# ── Secrets ─────────────────────────────────────────────────────────────────

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

# ── Build and diff (no activation) ──────────────────────────────────────────

build-thinkpad-x13:
    nh os build . -H thinkpad-x13
    # native: nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link

# Build and show the closure diff without activating.
diff-thinkpad-x13:
    nh os switch --dry . -H thinkpad-x13
    # native: nix store diff-closures /run/current-system "$(nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link --print-out-paths)"

build-homelab-x456urk:
    nh os build . -H homelab-x456urk
    # native: nix build .#nixosConfigurations.homelab-x456urk.config.system.build.toplevel --no-link

# ── Homelab deploy (deploy-rs over SSH) ─────────────────────────────────────

# Owner-only: show what deploy-rs would activate.
deploy-plan-homelab-x456urk:
    deploy --dry-activate .#homelab-x456urk

# Owner-only: activate the homelab over SSH.
deploy-homelab-x456urk:
    deploy .#homelab-x456urk

# Owner-only: deploy to the bootloader, then reboot the server.
deploy-homelab-x456urk-reboot:
    deploy --boot .#homelab-x456urk
    ssh homelab-x456urk 'sudo systemctl reboot'

# ── Direct link (cable, no Wi-Fi or tailnet in the path) ───────────────────

# Plug a cable between the ThinkPad and the homelab, then run this. The
# profiles never carry a default route, so Wi-Fi stays the normal path.
homelab-direct:
    #!/usr/bin/env bash
    set -euo pipefail

    wired_iface() {
      for dev in $(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="ethernet"{print $1}'); do
        if [ "$(cat "/sys/class/net/$dev/carrier" 2>/dev/null || echo 0)" = 1 ]; then
          printf '%s' "$dev"
          return 0
        fi
      done
      return 1
    }

    iface="$(wired_iface || true)"
    if [ -z "$iface" ]; then
      printf 'no wired interface with carrier: plug the cable first\n' >&2
      exit 1
    fi

    if nmcli -t -f NAME connection show | grep -qx homelab-direct; then
      sudo nmcli connection modify homelab-direct connection.interface-name "$iface" \
        ipv4.method manual ipv4.addresses 10.42.0.1/24 ipv4.never-default yes ipv6.method disabled
    else
      sudo nmcli connection add type ethernet ifname "$iface" con-name homelab-direct \
        ipv4.method manual ipv4.addresses 10.42.0.1/24 ipv4.never-default yes ipv6.method disabled
    fi
    sudo nmcli connection up homelab-direct >/dev/null

    ssh -o BatchMode=yes homelab-ts '
      set -e
      iface=""
      for dev in $(nmcli -t -f DEVICE,TYPE device status | awk -F: "\$2==\"ethernet\"{print \$1}"); do
        if [ "$(cat "/sys/class/net/$dev/carrier" 2>/dev/null || echo 0)" = 1 ]; then
          iface="$dev"
          break
        fi
      done
      if [ -z "$iface" ]; then
        echo "homelab: no wired interface with carrier" >&2
        exit 1
      fi
      if sudo nmcli -t -f NAME connection show | grep -qx homelab-direct; then
        sudo nmcli connection modify homelab-direct connection.interface-name "$iface" \
          ipv4.method manual ipv4.addresses 10.42.0.2/24 ipv4.never-default yes ipv6.method disabled
      else
        sudo nmcli connection add type ethernet ifname "$iface" con-name homelab-direct \
          ipv4.method manual ipv4.addresses 10.42.0.2/24 ipv4.never-default yes ipv6.method disabled
      fi
      sudo nmcli connection up homelab-direct >/dev/null
    '

    ping -c2 -W2 10.42.0.2 >/dev/null
    printf 'up: %s 10.42.0.1 <-> 10.42.0.2\n' "$iface"
    printf 'deploy: nixos-rebuild switch --flake .#homelab-x456urk \\\n'
    printf '  --target-host atalariq@10.42.0.2 --elevate=sudo\n'

homelab-direct-off:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo nmcli connection down homelab-direct >/dev/null 2>&1 || true
    ssh -o BatchMode=yes homelab-ts 'sudo nmcli connection down homelab-direct >/dev/null 2>&1 || true'
    printf 'direct link down\n'

# Read-only: show both ends of the direct link and whether they see each other.
homelab-direct-status:
    #!/usr/bin/env bash
    set -uo pipefail
    printf 'laptop:\n'
    ip -br addr show 2>/dev/null | grep -E '^(en|eth)' || true
    printf 'route: '
    ip route get 10.42.0.2 2>/dev/null | head -1 || true
    ping -c2 -W2 10.42.0.2 2>&1 | tail -2
    printf '\nhomelab:\n'
    ssh -o BatchMode=yes -o ConnectTimeout=5 homelab-ts '
      ip -br addr show 2>/dev/null | grep -E "^(en|eth)" || true
      ping -c2 -W2 10.42.0.1 2>&1 | tail -2
    ' || true

# ── Media and cache ────────────────────────────────────────────────────────

# Copy a finished download into the import folder on the homelab.
media-push PATH:
    #!/usr/bin/env bash
    set -euo pipefail
    test -e "{{ PATH }}" || { printf 'not found: %s\n' "{{ PATH }}" >&2; exit 1; }
    host=homelab-ts
    ping -c1 -W1 10.42.0.2 >/dev/null 2>&1 && host=atalariq@10.42.0.2
    rsync -rlptD --info=progress2 --chmod=D2775,F664 "{{ PATH }}" "$host:/data/media/downloads/incoming/"

# Copy an album or track into the beets import folder.
music-push PATH:
    #!/usr/bin/env bash
    set -euo pipefail
    test -e "{{ PATH }}" || { printf 'not found: %s\n' "{{ PATH }}" >&2; exit 1; }
    host=homelab-ts
    ping -c1 -W1 10.42.0.2 >/dev/null 2>&1 && host=atalariq@10.42.0.2
    rsync -rlptD --info=progress2 --chmod=D2775,F664 "{{ PATH }}" "$host:/data/media/downloads/music-incoming/"

# Tag and move everything waiting in the beets import folder. Beets keeps the
# source mode on move, so the library is made group-readable afterwards.
music-import:
    #!/usr/bin/env bash
    set -euo pipefail
    host=homelab-ts
    ping -c1 -W1 10.42.0.2 >/dev/null 2>&1 && host=atalariq@10.42.0.2
    ssh "$host" 'beet import -q /data/media/downloads/music-incoming'
    ssh "$host" 'chgrp -R media /data/media/music && chmod -R g+rX /data/media/music'

# Push a store path (or the running system) to the Attic cache.
cache-push *PATHS:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{ PATHS }}" ]; then
      attic push main "$(readlink -f /run/current-system)"
    else
      attic push main {{ PATHS }}
    fi

# ── Inputs ─────────────────────────────────────────────────────────────────

# nh has no update subcommand; keep native. Brave comes from the community
# flake until nixos-unstable includes the upstream re-add.
update *inputs:
    nix flake update {{ inputs }}

# ── Store hygiene ──────────────────────────────────────────────────────────
# Keep 14 days and the 5 newest generations; everything older is collectable.
gc:
    nh clean all --keep-since 14d --keep 5
    # native: sudo nix-collect-garbage --delete-older-than 14d

# nh has no optimise equivalent; keep native.
optimise:
    sudo nix-store --optimise
