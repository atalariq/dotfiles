# Navidrome clients

Two experimental clients are installed on the ThinkPad. The homelab stays
headless and runs the server only.

- **Ratune** — Rust TUI, gapless playback, album art, fuzzy library, MPRIS.
  `programs.ratune.enable = true`; the Home Manager module only installs the
  package. Configuration stays native at `~/.config/ratune/config.toml`.
- **NaviBeat** — unfree AppImage from the community flake. Run the terminal
  client with `navibeat --tui`. It needs a display for the windowed mode; the
  TUI works over SSH and on a headless machine.

Server URL for first run:

```text
http://homelab-x456urk:4533
```

Use the normal Navidrome account. Ratune stores the password in the OS keyring
(or `password_command`); NaviBeat prompts on first launch. Do not put the
password in the Nix store.

Ratune:

```sh
ratune
```

NaviBeat terminal mode:

```sh
navibeat --tui
```

Update the pinned clients with the rest of the flake inputs:

```sh
nix flake update ratune navibeat
```

Skipped on purpose: sonic-tui, TerminalDrome (both require mpv at runtime) and
Aulos (GUI-only).
