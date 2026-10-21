# Validation record — 21 October 2026

## Machine and preservation

Executed on x86_64-linux, NixOS, ThinkPad X13 Gen 2a AMD (`20XH005GUS`),
approximately 16 GB RAM. Nix 2.34.9. Existing hardware configuration was copied
byte-for-byte: SHA-256
`de26785c49cfae2ec26f62efdf4d626aa4f81d5f5c043300bb355592d7a05ed3`.
Both system stateVersion and the new HM compatibility baseline are `26.05`.
Original `/etc/nixos` files and the user's pre-existing legacy modifications
were preserved. No real-home links, login shell, system profile, activation,
firmware update, enrollment, boot selection or running service was changed.

## Passed

- `python3 -B -m unittest discover -s tests -v`: **19 tests passed**, no skips.
  Tests use temporary homes/checkouts, including checkout/config paths with spaces.
  They cover Nix-free installation, idempotency, direct edits, local overrides,
  copied Fish startup without optional tools, plan/doctor non-mutation, collisions,
  broken/foreign/intermediary symlinks, backups, unsafe ancestors, invalid manifests,
  partial failure/retry, stale-link reporting, unsupported app-scoped full apply,
  HM/helper interoperability, build failure and activation refusal.
- NixOS integrated Home Manager evaluation and full system build succeeded.
  The final build also runs Mango and Niri configuration validators as dependencies.
- Standalone Home Manager activation package built for a fixture home on
  x86_64-linux; its activation script was **not run**. The shared native-link
  helper's check/apply interoperability was exercised only in disposable homes.
- Home Manager derivation evaluation passed for **x86_64-linux, aarch64-linux,
  aarch64-darwin**. This is evaluation evidence, not runtime evidence for remote OSes.
- Laravel and Android dev shells built on x86_64-linux.
- Laravel smoke check passed: PHP 8.4.26, Composer 2.10.3, Node 22.23.3;
  bcmath, intl, PDO MySQL, PDO SQLite, zip, mbstring and openssl were loaded.
- Android smoke check passed: OpenJDK 17.0.20.1, adb 37.0.0, `/dev/kvm` exists.
  No emulator, device pairing, SDK installation or Android build was run.
- Native Niri config passed `niri validate -c apps/niri/config.kdl` using Niri 26.04.
- Native Mango config passed `mango -p -c apps/mango/config.conf` using the
  exact flake-pinned Mango package. Validation caught old spellings of startup,
  border and gap options; these were corrected before delivery.
- libfprint 1.94.100 hardware database includes `usb:v27C6p6594*`.
  Evaluated `security.pam.services.login.fprintAuth` is true.
- Noctalia package is 5.3.0. Native configuration/IPC APIs were verified against
  its pinned documentation. Native TOML syntax and `git diff --check` passed.

## Limits and pending runtime checks

- Intel macOS Nix evaluation was attempted and correctly failed: pinned Nixpkgs
  26.11 dropped x86_64-darwin. Intel Macs retain the config-only/manual path;
  this delivery does not silently add an older package universe.
- macOS, non-NixOS Linux, ARM Linux and WSL runtime activation were not tested.
  No remote target machine was available. There is no native Windows adapter.
- Camera `13d3:5439` and video0/video1 were detected; capture quality, microphone,
  browser permissions, suspend/resume, battery behavior, external displays,
  Bluetooth and fingerprint enrollment/unlock require post-approval runtime tests.
- SDK platform/image/license downloads and project Composer/npm/Gradle dependencies
  are intentionally not installed globally. No sample app build is claimed.
- Neovim is a native plugin-free baseline. No plugin lockfile was invented and
  no existing plugin setup was silently imported.
- The real-home plan reports existing Fish/Yazi/Bat ancestor symlinks and
  Neovim/Starship/Mango conflicts. Deployment remains pending explicit migration
  and activation approval. See `dotfiles-v1.md` for backup and recovery instructions.
- Two independent review agents were attempted but both hit the account usage
  limit. The primary agent completed the spec/correctness review directly;
  independent review is not claimed.

## Build evidence

Build-only logs are under `/tmp/dotfiles-*-build.log` and
`/tmp/dotfiles-delivery-build.log` for this session. These logs are temporary;
regenerate through `./dot build --host thinkpad-nixos` as needed. The root lock
retains the original Nixpkgs/Mango/Noctalia pins and adds a real resolved Home
Manager pin. No apply/update command was used against the real home.

Final `./dot build --host thinkpad-nixos` output:
`/nix/store/6p1q0iprqc54mgwsjllk1gmcrvhfv9hh-nixos-system-thinkpad-nixos-26.11.20261015.fe13242`.
This output was built successfully and never activated.
