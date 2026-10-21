# Restoration verification — 22 October 2026

## Passed on this ThinkPad

- Full filtered `./dot build --host thinkpad-nixos` succeeded. Output:
  `/nix/store/38vsg2sxrkfslmqmhiaigplfs514lizi-nixos-system-thinkpad-nixos-26.11.20261015.fe13242`.
- `python3 -B -m unittest discover -s tests -v`: 20 tests, all passed.
  Includes idempotency, direct edits, conflicts, foreign/owned ancestor symlinks,
  backups, temporary homes, HM interoperability and activation refusal/failure.
- Native Mango parser passed against the original split configuration as a build
  dependency and against the live original source. `mmsg dispatch reload_config`
  returned success; Mango PID 102392 and Noctalia PID 102421 were unchanged.
- 37 Fish files parsed with fish --no-execute. Native Yazi and Noctalia TOML parsed.
- Original Neovim vim.pack configuration started in an isolated HOME using copied
  existing plugins. Ten tree-sitter parsers compiled after adding tree-sitter and
  the C toolchain. The obsolete live_server import was changed to kitehost.
- Original Yazi started in an isolated HOME. Single-tab quit and multiple-tab
  confirmation/quit passed with the corrected synchronous plugin entry and
  main-thread asynchronous dialog. No Yazi errors were logged.
- Closure comparison removes Niri 26.04, its service and portal config. Mango
  portals remain wlr for screencast/screenshots and gtk for the general backend.
- Built greetd unit contains X-RestartIfChanged=false. It must remain running
  through activation; changed login command takes effect on its next start.
- Original /etc/nixos/configuration.nix and captured host copy are identical.
  Hardware SHA256 in both locations:
  `de26785c49cfae2ec26f62efdf4d626aa4f81d5f5c043300bb355592d7a05ed3`.
  system.stateVersion remains 26.05. Flake pins were not updated.
- Native links were migrated after archiving conflicts. Obsolete placeholders,
  Niri sources/deployed config and old setup scripts were archived then removed.

## Activation status

The restored native links and Mango reload are applied. The operator activated
`/nix/store/yq593fczvscaww6r12nqdqy9s6dad9bj-nixos-system-thinkpad-nixos-26.11.20261015.fe13242`.
/run/current-system and the system profile both resolve to that output.
Home Manager is active with Result=success. System and user failed-unit lists
are empty. Mango and Noctalia retain their original PIDs. Live `dot doctor`
passes with all selected commands available and mappings owned.

The later 38vsg2 output above contains only the aria2c diagnostic-command name
correction and comment updates. Packages and system settings are unchanged;
it is built but was not activated. No additional switch was requested.

Logs: /tmp/dotfiles-restoration-final-build.log and
/tmp/dotfiles-restoration-final-tests.log. Temporary logs are not durable artifacts;
reproduce using the commands above. Backup details are in restoring-original-configs.md.

## Earlier validation retained

The preceding integration built Laravel and Android shells on x86_64-linux:
PHP 8.4/Composer/Node22 with the required PHP extensions; JDK17/adb with /dev/kvm.
Standalone HM built on x86_64-linux and evaluated on aarch64-linux/aarch64-darwin.
These results predate this restoration; remote-platform runtime is not claimed.
Intel macOS remains config-only because the pinned Nixpkgs dropped x86_64-darwin.

## Remaining physical/runtime checks

Camera capture, fingerprint enrollment/unlock, suspend/resume, battery behavior,
external displays and Bluetooth/audio require real use. The camera enumerates as
uvcvideo and libfprint's hardware database includes the detected 27c6:6594 reader;
this does not establish successful enrollment or capture. SDK/image/license and
project dependency downloads remain user/project state. No Android application,
video recording, screenshot, firmware update or fingerprint enrollment was run.

Two independent review agents were attempted earlier and both hit usage limits.
The primary agent reviewed the specification, preservation boundaries, ownership
and version changes directly; an independent review is not claimed.
