# Homelab

The `homelab-x456urk` host is a headless NixOS machine built from a
second-hand ASUS X456URK: a 24/7 box for media, backup and staging services.
It is installed fresh from this flake, with a volatile root and an explicit
persistence list.

## Hardware

| Item | Value |
| --- | --- |
| Model | ASUS X456URK (battery dead, always on AC) |
| CPU | Intel Core i5-7200U (2C/4T), Intel HD 620 |
| RAM | 8 GB (zram swap, no disk swap) |
| GPU | NVIDIA GeForce 930MX — unused and blacklisted |
| System disk | V-GEN 128 GB SSD (`ata-V-GEN04SM24HUI128GBSDK_RLA00000000000010281`) |
| Media disk | HGST 1 TB (`ata-HGST_HTS541010A9E680_JD1008DM2BNHTV`) |
| Network | `enp2s0` wired (WoL), `wlp3s0` WiFi |
| Boot | UEFI, systemd-boot, Secure Boot off |

The SSD is wiped on install: the existing Arch + Windows + LUKS/LVM layout is
replaced. The media HDD is only touched when `includeDataDisk` is flipped to
`true` in `hosts/nixos/homelab-x456urk/disko.nix`, and that must happen after
the media backup has been verified.

## Layout

| Piece | Choice | Where |
| --- | --- | --- |
| System disk | ESP 1 GiB + btrfs label `nixos` | `hosts/nixos/homelab-x456urk/disko.nix` |
| Subvolumes | `root`, `nix`, `persist`, `log` | same |
| Root | btrfs `root`, deleted and recreated at boot | `modules/nixos/impermanence.nix` |
| Media disk | XFS label `data` mounted on `/data`, `noatime,nofail` | `disko.nix` |
| Persistence | `environment.persistence."/persist"` | host + module |
| Boot | systemd-boot, 4 generations | `hardware.nix` |
| Access | SSH keys + Tailscale, no passwords | host `default.nix` |

`/` is volatile. Only `/boot`, `/nix`, `/persist`, `/var/log` and the declared
bind mounts survive a reboot. `/home` is bound from `/persist/home`, so user
data lives on the persistence subvolume.

## Before installing

1. **Back up everything.** The SSD wipe removes Arch (`vg0-home`, 24 G),
   Windows (`sda1`, 40 G) and the old boot entries. The HDD holds the media
   library and is wiped too; copy it out first and verify checksums. A manifest
   like this makes the restore check deterministic:
   ```sh
   cd /path/to/backup
   find . -type f -printf '%P\0' | sort -z | xargs -0 sha256sum > /tmp/media.sha256
   ```
2. Confirm the borrowed backup medium has room; a 1 TB disk is the practical
   minimum, 2 TB is comfortable.
3. Run `smartctl -x /dev/disk/by-id/ata-HGST_HTS541010A9E680_JD1008DM2BNHTV`
   and check reallocated/pending sectors and CRC errors. The disk already had a
   high load-cycle count; do not install if the SMART result is bad.
4. Disconnect the backup disk. `disko.nix` already sets
   `includeDataDisk = true`, so the next destructive command wipes both the SSD
   and the HDD.
5. Fill the homelab sops file from a trusted machine. The same identity is
   copied to the target in the next step; `just homelab-bootstrap` prompts for
   the `atalariq` password and writes its hash, because
   `users.mutableUsers = false` locks console and sudo without it.

   ```sh
   just secrets-edit secrets/homelab-x456urk/secrets.sops.yaml
   just secrets-check secrets/homelab-x456urk/secrets.sops.yaml
   ```

6. The Attic JWT secret and Restic/R2 credentials are fields in the same sops
   file (`attic_env`, `restic_env`); no plaintext file is written manually.

## Installing directly from the target installer

This is the supported path when no direct Ethernet cable is available. The
installer needs internet for the flake inputs and packages.

1. Connect the installer to Wi-Fi and verify connectivity:

   ```sh
   nmtui
   # If nmtui is unavailable:
   # wpa_passphrase "SSID" "PASSWORD" | sudo tee /etc/wpa_supplicant.conf
   # sudo wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf
   # sudo dhcpcd wlp3s0
   ping -c1 nixos.org
   ```

   USB tethering from a phone is the fallback when the Wi-Fi isolates clients.

2. Copy the **working tree**, not just committed HEAD. The homelab files may
   still be staged/uncommitted, and `path:` flakes include them:

   ```sh
   rsync -a --exclude .git --exclude .beads --exclude result \
     ~/.dotfiles/ /mnt/usb/dotfiles/
   ```

3. On the installer, mount the USB and enter the checkout:

   ```sh
   sudo mkdir -p /mnt/usb
   sudo mount /dev/disk/by-label/<USB-LABEL> /mnt/usb
   cd /mnt/usb/dotfiles
   ```

4. Fill the homelab sops file on the trusted machine first, then copy the age
   key path. The one-command bootstrap checks the secrets, prompts twice for the
   `atalariq` password, asks you to type `WIPE`, formats both disks, seeds the
   age key and password hash, and runs `nixos-install`:

   ```sh
   nix shell nixpkgs#just -c just homelab-bootstrap \
     ~/.config/sops/age/homelab-x456urk.txt
   sudo reboot
   ```

   The command refuses to continue while `CHANGE_ME` remains in
   `secrets/homelab-x456urk/secrets.sops.yaml`.

5. If you prefer the manual path, format/mount with
   `sudo just disko-homelab-x456urk`, then seed the age key and run
   `nixos-install --flake "path:$(pwd)#homelab-x456urk" --root /mnt
   --no-root-passwd` yourself.

## Alternative: installing over SSH with direct cable and dnsmasq

The kost router is not administrable and the Wi-Fi may isolate clients, so a
direct cable between the ThinkPad (USB Ethernet adapter) and the homelab's
`enp2s0` remains an option:

1. On the ThinkPad give the adapter a static address and run a DHCP server for
   the installer:

   ```sh
   ip -br link                    # find the USB adapter name, e.g. enp0s20u1
   sudo ip addr add 10.10.10.1/24 dev <usb-adapter>
   sudo dnsmasq --interface=<usb-adapter> --bind-interfaces \
        --dhcp-range=10.10.10.100,10.10.10.150,12h
   ```

2. Boot the homelab into the NixOS installer (USB) and enable SSH, or boot its
   existing Arch with `sshd` running.
3. From the ThinkPad, install:

   ```sh
   just install-homelab-x456urk root@10.10.10.100
   ```

   `nixos-anywhere` kexecs the target, lets it DHCP from dnsmasq, runs disko
   and installs the closure copied from the ThinkPad. No internet is needed on
   the target during this step.
4. After the first boot, the server needs internet for Tailscale and Nix. Use a
   travel router or Wi-Fi uplink; a direct cable to the ThinkPad is only an
   install-time link.

## First boot

- Log in on the console with the user password created above.
- `sudo tailscale up` and open the printed URL from the ThinkPad.
- Verify `/persist` is mounted and `/var/log` survived a reboot; then reboot a
  second time and confirm the root was recreated (`findmnt /` shows `subvol=/root`).
- Create the cache and trust it on the ThinkPad:

  ```sh
  sudo attic login homelab http://127.0.0.1:8080 <root-token>
  sudo attic cache create main
  sudo attic cache info main   # copy the public key
  ```

  Then set `dotfiles.system.binary-cache.client` on the ThinkPad with the URL
  `http://homelab-x456urk:8080/main` and that public key, and rebuild.

## Deploying with deploy-rs

deploy-rs deploys both NixOS and nix-darwin hosts over SSH. The local ThinkPad
keeps the native `nh os switch`/`nixos-rebuild` recipes because its SSH server
is intentionally disabled.

- `nix develop` provides the deploy-rs CLI from the flake input.
- `just deploy-plan-homelab-x456urk` builds and runs `--dry-activate`.
- `just deploy-homelab-x456urk` switches the homelab over SSH.
- `just deploy-homelab-x456urk-reboot` deploys with `--boot`, then reboots.
- `deploy --dry-activate .#macmini-lab` and `deploy .#macmini-lab` handle the Mac mini.
- `just apply-thinkpad-x13` remains the local laptop activation path.

### One-time bootstrap before deploy-rs

deploy-rs needs non-interactive privilege escalation. A host that still has
password-required sudo (or no sops service yet) cannot be switched by
`deploy`; bootstrap it once with an owner-entered password, then deploy.

Homelab from the ThinkPad. Run this as the normal user, not with local
`sudo`: local root does not read the user's `~/.ssh/config`, so an
`homelab-ts` alias would fail to resolve. `--elevate=sudo` handles the
remote privilege step.

```sh
nixos-rebuild switch --flake path:$PWD#homelab-x456urk \
  --target-host atalariq@homelab-x456urk --elevate=sudo

# Or, if the user SSH config has the alias:
nixos-rebuild switch --flake path:$PWD#homelab-x456urk \
  --target-host homelab-ts --elevate=sudo

ssh homelab-ts 'sudo -n true'   # must succeed before deploy
```

Then:

```sh
just deploy-plan-homelab-x456urk
just deploy-homelab-x456urk
```

For a manual fallback when deploy-rs is unavailable:

```sh
nix build .#nixosConfigurations.homelab-x456urk.config.system.build.toplevel
nix copy --to ssh://homelab-ts ./result
ssh -t homelab-ts 'sudo $(readlink -f /nix/var/nix/profiles/system)/bin/switch-to-configuration switch'
```

For the Mac mini, enable Remote Login, add an SSH alias (`macmini-lab`) in
`~/.ssh/config`, and make sure the administrator can approve sudo. `deploy-rs`
uses `interactiveSudo = true` for that node.
Manual fallback:

```sh
nix build .#darwinConfigurations.macmini-lab.system
ssh macmini-lab 'sudo /nix/store/.../darwin-rebuild switch --flake ...'
```

Use `deploy --dry-activate .#<host>` first; it evaluates and builds the
activation path without switching. If activation fails, deploy-rs performs its
magic rollback, but a configuration that fails to boot still needs a manual
generation rollback.

The homelab node uses `hostname = "homelab-x456urk"` and `sshUser =
"atalariq"`; resolve that name through Tailscale MagicDNS/Headscale, or change
it in `flake/hosts.nix`. The homelab sets `security.sudo.wheelNeedsPassword =
false` for the only human user, so deploy-rs can activate non-interactively.

The Darwin node uses `sshUser = "praktikan"`, `remoteBuild = true` (the deploy
runs from the ThinkPad), and `interactiveSudo = true` because the Mac prompts
for the administrator password. Enable Remote Login on it. `macmini-lab` is an
SSH alias for the lab machine; point it at the lab's address or change the
hostname in `flake/hosts.nix`.

deploy-rs provides magic rollback for failed activations. It does not roll back
a configuration that fails to boot; keep a previous generation in the boot menu
and use the host's rollback command over SSH if a boot regression appears.

## Network, secrets, and service endpoints

The host uses NetworkManager for Ethernet, Wi-Fi, and phone USB tethering. The
tailnet is Headscale (`https://headscale.atalariq.dev`), not Tailscale SaaS.
Secrets are decrypted from `secrets/homelab-x456urk/secrets.sops.yaml` by the
dedicated age key; the key is seeded to `/persist/var/lib/sops-nix/key.txt`.

Before first boot, copy the age private key to the target. The canonical local
key is `~/.config/sops/age/homelab-x456urk.txt`:

```sh
sudo install -d -m 0700 /mnt/persist/var/lib/sops-nix
sudo install -m 0600 ~/.config/sops/age/homelab-x456urk.txt \
  /mnt/persist/var/lib/sops-nix/key.txt
```

Fill the encrypted file with the matching identity:

```sh
just secrets-edit secrets/homelab-x456urk/secrets.sops.yaml
just secrets-check secrets/homelab-x456urk/secrets.sops.yaml
```

Required values:
- `wifi_ssid`, `wifi_psk`
- `headscale_authkey` (Headscale preauth key)
- `attic_env` (Attic JWT secret)
- `restic_env` (R2 credentials and restic password)
- `bookorbit_env` (Postgres/JWT/setup token and app URL)

The Wi-Fi profile is generated from sops before NetworkManager starts. The PSK
is never in the Nix store or Git.

Enabled services and endpoints:

| Service | Port | Access |
|---|---:|---|
| Jellyfin | 8096/tcp | LAN + tailnet |
| Navidrome | 4533/tcp | LAN + tailnet |
| Seerr | 5055/tcp | LAN + tailnet |
| Sonarr / Radarr / Prowlarr / Bazarr / qBittorrent | app defaults | tailnet only |
| aria2 RPC | 6800/tcp | tailnet only |
| Attic | 8081/tcp | tailnet only |

aria2 runs on the homelab with `--rpc-listen-all`, but its port is only opened
on `tailscale0` and the RPC secret comes from sops. Point Aria2 Explorer at
`http://homelab-x456urk:6800/jsonrpc` and downloads land in
`/data/media/downloads/incoming` without a detour through the laptop.

## Media restore and Jellyfin

Jellyfin runs natively and reads `/data/media`; its config and cache live in
`/persist` so library scans do not hit the old HDD for every request.

1. Confirm the XFS mount:

   ```sh
   findmnt /data
   df -T /data        # Type must be xfs
   ```

2. Mount the verified backup read-only and restore:

   ```sh
   sudo mkdir -p /mnt/backup
   sudo mount -o ro /dev/disk/by-uuid/<BACKUP-UUID> /mnt/backup
   sudo rsync -aHAX --info=progress2 /mnt/backup/ /data/media/
   sync
   ```

3. Verify the checksum manifest, then fix the shared group and setgid bits:

   ```sh
   cd /data/media && sudo sha256sum -c /tmp/media.sha256
   sudo chown -R atalariq:media /data/media
   sudo find /data/media -type d -exec chmod 2775 {} +
   sudo find /data/media -type f -exec chmod 664 {} +
   ```

4. Open Jellyfin from the LAN at `http://homelab-x456urk:8096` (or through
   Tailscale), add the libraries, and run a scan:

   - Movies → `/data/media/movies`
   - Shows → `/data/media/series`
   - Music → `/data/media/music`

5. Play one file directly and one that forces a transcode; check
   `systemctl status jellyfin` and `vainfo`. The HD 620 is suitable for VA-API
   decode/H.264 encode, not for heavy HEVC encoding.

## Reinstalling the ThinkPad

`hosts/nixos/thinkpad-x13/disko.nix` describes the target layout but is not
imported by the running host; the current system still uses UUID-based
fileSystems. From a checkout on USB or another machine:

```sh
just disko-thinkpad-x13            # destructive, mounts the new layout
nixos-generate-config --root /mnt  # writes a fresh hardware-configuration.nix
nixos-install --flake .#thinkpad-x13
```

Secure Boot keys (`/etc/secureboot`) and TPM2/pcrlock enrollment do not survive
a reinstall; back up the key bundle or expect to re-enroll in firmware.
