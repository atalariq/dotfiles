# Dotfiles v1 operation and migration

## Boundaries

`config/` holds the original native configuration, usable by manual copy without Nix or sibling
apps. `apps/manifest.json` contains IDs, baseline selection, packages, required
commands and mappings. `bootstrap/dot.py` validates the entire manifest before
linking anything. Home Manager calls the same code through `hm-links.py` at
its preflight and write boundaries. It deliberately does not also generate
`home.file` or `programs.*` configuration for those files. This preserves a
single ownership model and avoids disabling Home Manager's collision checks.

A Home Manager build also validates the manifest against the source snapshot.
At activation, preflight validates the actual live checkout again. Foreign
files are rejected even if their contents happen to match. Validated direct
links and links through a store intermediary are both recognized by their
resolved source. Directory links cover config-only trees such as Neovim, Yazi and Fish functions/
completions/conf.d. Mixed roots retain file mappings and unmanaged local state.
An existing ancestor link is accepted only when it resolves to the exact declared
source tree; foreign ancestor links remain conflicts.

`nix/` composes package selection and HM. `hosts/thinkpad-nixos/` contains the
actual machine configuration captured from `/etc/nixos`, not a reusable
hardware example. `devshells/` contains opt-in development toolchains. The
root flake pins packages; no new module framework is used.

## Commands and host selection

Python 3.10+ is required. `dot` does not install Python or Nix. `--config-only`
never invokes Nix, downloads, sudo or package managers. Install applications
with the platform package manager when using that mode. Config-only works
without a Git executable as well.

`--host NAME` overrides hostname detection. Unknown names use the baseline
and standalone HM on x86_64/aarch64 Linux or Apple Silicon macOS. Intel macOS
uses config-only because the pinned Nixpkgs 26.11 dropped x86_64-darwin support. WSL uses the Linux path;
Windows manages its physical hardware. Existing installations must retain
their original Home Manager `homeStateVersion` in a host record; `26.05` is
the default only for a new HM installation. Existing non-NixOS systems are not
managed by this repo. nix-darwin and system-manager remain future integrations.

Known host records contain explicit username, homeDirectory, checkout, system,
HM stateVersion, integration and app differences. `host.local.json` replaces
its tracked counterpart; supply the complete record. Identity records are
public build inputs, never credential files. Native overrides follow
`*.local.*` and are ignored by Git, but only load where the application
supports it (see each folder README).

`--home /absolute/path` and `--config-home /absolute/path` support disposable
homes and alternate config roots. Otherwise HOME and XDG_CONFIG_HOME are
used. Foreign symlinked target ancestors are rejected rather than silently traversed.
`--app` is repeatable and only allowed together with `--config-only`.

Plan reports static intent and conflicts, not a computed closure diff. Doctor
also checks executable availability and link ownership, returning nonzero for
missing commands, absent links, conflicts, or unsafe ancestors. It does not
run login commands. Update alone updates the flake lock and prints its diff;
it never updates application plugins or activates anything. Apply/build use
`--no-update-lock-file --no-write-lock-file` and fail if inputs need relocking.

Build snapshots include only the v1 source directories and lock/flake files.
Native local/private overrides, caches, backups and legacy directories are
excluded. Host local records are deliberately materialized as the snapshot's
host.json. Application files still link to the ORIGINAL checkout string.
Prefer `./dot build` over a raw `path:` flake build of a dirty working tree;
raw path inputs can copy ignored local files into the public Nix store.

## ThinkPad integration and activation

The canonical source is this checkout's root flake. `/etc/nixos` is preserved
as the original source reference. Existing hardware, disk UUIDs, boot options
and system.stateVersion 26.05 remain unchanged.

The system selects Mango with Noctalia 5.3.0, greetd/tuigreet authenticated login,
PipeWire/portals, libinput, Bluetooth, GNOME Keyring, fprintd, fwupd, AMD firmware,
power-profiles-daemon, 25% zram, fstrim, Android Studio, KVM and rootless Podman.
Niri is removed. greetd has restartIfChanged=false: a configuration switch must
preserve the running login session. A changed greeter command takes effect on
its next start; do not restart it during an active desktop session.

Original configs have been restored with archived conflicts. See
[restoration record](restoring-original-configs.md). Native links are live, so
configuration edits can affect running applications independently of Nix.

Full apply builds first, prints the immutable output and (for NixOS) the closure
diff, then requires the exact text `activate HOST`. Refusal/EOF leaves the active
system/home untouched. Only after approval does it set the system profile and
invoke that output's `switch-to-configuration switch`. This avoids a second
unreviewed evaluation. There is no `--yes` bypass. Applying user-only HM also
requires confirmation after its build. Do not run this command from a root shell.

## Laptop verification after approved activation

Hardware-dependent checks still require actual use:

1. Log into Mango; verify Noctalia, audio, microphone, brightness,
   notifications, Bluetooth, Wi-Fi, screen sharing and an external display.
2. Run `fprintd-enroll` as your regular user and then `fprintd-verify`. Enrollment
   requires your physical finger and changes device state; it was not run.
   Password authentication remains available. Fingerprint login does not supply
   the password needed to unlock an encrypted GNOME Keyring automatically.
3. The detected camera is Azurewave `13d3:5439`, exposed by uvcvideo as video0/1.
   Check `v4l2-ctl --list-devices`, the physical shutter and browser permission;
   test a video call. Detection alone does not prove capture quality.
4. Check suspend/resume, lid lock and battery use on AC/battery. Noctalia locks
   on PrepareForSleep. Its saved GUI settings can override native preferences.
5. Use `fwupdmgr get-devices` to inspect firmware; upgrades are separate explicit
   actions. No firmware update or fingerprint enrollment happened during build.
6. Re-login for `kvm` membership; verify emulator acceleration and `adb devices`
   after enabling USB debugging on your Android phone.

Fingerprint `27c6:6594` is present in the installed libfprint hardware database
and in [upstream's supported list](https://fprint.freedesktop.org/supported-devices.html).
HM module and collision semantics were checked against its pinned source and
[official manual](https://nix-community.github.io/home-manager/usage/dotfiles.html).
Noctalia keybind/config APIs were checked in the pinned v5.3.0 source documentation.

## Development workflows

After the checkout is committed, run `nix develop /absolute/checkout#laravel`
from a project folder (quote a path containing spaces). It supplies PHP 8.4,
Composer, Node 22/npm, SQLite and common PHP extensions including bcmath,
intl, zip, PDO MySQL and PDO SQLite. `composer install` and `npm ci` consume
project locks; application creation, database migration and dependency downloads
are intentional project actions. SQLite is a simple local default; project
MySQL/Postgres/Redis services can use rootless Podman. No database is exposed
or globally started by this config. Pin/adapt a shell in each project's flake
when a course needs different PHP/Node versions; commit that project's lock.

Android Studio is installed on the ThinkPad only. Use the SDK manager for the
specific platforms/emulator images/licenses needed by a project. The Android
shell supplies JDK 17, adb and the conventional `$HOME/Android/Sdk` path (override
ANDROID_HOME for another path); use `./gradlew`, not an unrelated global Gradle.
Choose the JDK required by the project's Android Gradle Plugin (adjust the
project shell for newer JDK requirements). Studio's bundled runtime is independent
of the shell JDK. SDKs, Gradle caches, AVD images and signing keys are user state,
not Git-managed. Android Studio/SDK first-run downloads are not claimed complete.

## Failure recovery and ownership

Config-only preflights all mappings before touching destinations. Existing
objects stay intact unless `--backup` is explicitly provided; backups use unique
names and never overwrite previous backups. Foreign/broken symlinks are conflicts.
A mid-apply failure reports completed links and backups, leaves them for inspection,
and can be resumed after fixing the cause. The ownership ledger is under
`~/.local/state/dotfiles/links.json`. Removed/unselected mappings are retained and
reported with exact paths; inspect `readlink` and remove only the obsolete symlink.
No automatic recursive cleanup is performed.

Nix activation can partially fail after the system profile or services changed;
inspect the output and service logs. Select a previous boot generation or explicitly
use `nixos-rebuild --rollback` only when you intend to activate it. Standalone HM
can activate an earlier generation. Neither rollback restores live native config
contents: recover those with Git or the preserved backup. Moving/deleting a checkout
breaks live links and requires updating the host record and reapplying.

## Verification boundary

`python3 -B -m unittest discover -s tests -v` exercises the public CLI in temporary
homes/checkouts, including unavailable optional commands and refusal/failure paths.
Orchestration tests replace Nix with a recording fixture; they never activate the
real system. Real builds validate NixOS/HM outputs separately. See
[validation.md](validation.md) for exact outcomes and platform limitations.
