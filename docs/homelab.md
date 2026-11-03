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
5. Create the password hash file **on the target's `/persist`** before the
   first boot, otherwise `users.mutableUsers = false` locks console and sudo.
   During a direct install, run this after `disko` has mounted `/mnt`:

   ```sh
   sudo mkdir -p /mnt/persist/secrets
   nix shell nixpkgs#mkpasswd -c mkpasswd -m sha-512 > /mnt/persist/secrets/atalariq.passwd
   chmod 600 /mnt/persist/secrets/atalariq.passwd
   ```

   With `nixos-anywhere`, either use `--phases kexec,disko,install` so the
   target stays mounted, or supply the files with `--extra-files`.

6. Create the Attic JWT secret on the target before the first boot:

   ```sh
   sudo mkdir -p /mnt/persist/var/lib/atticd
   sudo sh -c 'printf "ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=%s\n" \
        "$(openssl genrsa -traditional 4096 | base64 -w0)" \
        > /mnt/persist/var/lib/atticd/atticd.env'
   sudo chmod 600 /mnt/persist/var/lib/atticd/atticd.env
   ```

   It is persisted with `/var/lib/atticd` and never enters Git or the store.

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

4. Format and mount both disks. This is destructive:

   ```sh
   sudo just disko-homelab-x456urk
   ```

5. Create the password hash and Attic secret under `/mnt/persist` as described
   above, before the first boot.

6. Install without asking for a root password. The user's password comes from
   the persisted hash file:

   ```sh
   sudo nixos-install \
     --flake "path:$(pwd)#homelab-x456urk" \
     --root /mnt \
     --no-root-passwd
   sudo reboot
   ```

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
| Sonarr / Radarr / Prowlarr / Bazarr / qBittorrent | app defaults | tailnet only |
| Actual Budget | 5006/tcp | tailnet only |
| Vikunja | 3456/tcp | tailnet only |
| Memos | 5230/tcp | tailnet only |
| BookOrbit | 3000/tcp | tailnet only |

BookOrbit runs as the official app container plus a pgvector PostgreSQL
sidecar. App data and Postgres live under `/var/lib/bookorbit` (persisted),
while the library is `/data/media/books` on the XFS disk. The official image is
intentionally not exposed on the LAN; use the tailnet or an authenticated
reverse proxy.

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
