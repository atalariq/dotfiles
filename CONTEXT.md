# Dotfiles Domain Glossary

## Modules

A **module** is any stow-able config directory — a self-contained piece of the dotfiles that can be deployed or skipped independently.

| Module    | Category | Description                                               |
|-----------|----------|-----------------------------------------------------------|
| kitty     | app      | Terminal emulator config + themes                         |
| fish      | app      | Fish shell: config, conf.d/, functions/, completions/     |
| yazi      | app      | TUI file manager with plugins and flavors                 |
|| zed       | app      | Text editor: settings, keymaps, themes                    |
|| nvim      | app      | Neovim config + `NVIM_APPNAME` profiles (`nvim`, `nvim-minimal`) |
|| zellij    | app      | Terminal multiplexer                                      |
| mpd       | app      | Music Player Daemon + ncmpcpp + rmpc clients              |
| mpv       | app      | Video player: config, keybinds, scripts                   |
| imv       | app      | Image viewer                                              |
| aria2     | app      | Download manager                                          |
| surge     | app      | Network proxy                                             |
| yt-dlp    | app      | YouTube/media downloader                                  |
| htop      | app      | Process viewer                                            |
| lazygit   | app      | Git TUI                                                   |
| tldr      | app      | Tealdeer (simplified man pages)                           |
| scholar   | app      | Zotero TUI                                                |
| bitwarden | app      | Bitwarden CLI (rbw)                                       |
| espanso   | app      | Text expander (disabled by default)                       |
| glow      | app      | Markdown renderer (disabled by default)                   |
| bat       | app      | Cat with syntax highlighting (minimal/lab profile)        |
| mango     | desktop  | mangoWM Wayland compositor config                         |
| niri      | desktop  | niri scrollable-tiling Wayland compositor config          |
| noctalia  | desktop  | Noctalia desktop shell + GTK/Qt theming                   |
| hyprland  | desktop  | Hyprland WM (legacy, disabled)                            |
| wal       | desktop  | pywal color scheme system                                 |
| fonts     | misc     | Custom fonts + fontconfig                                 |
| scripts   | misc     | Utility scripts under ~/.local/script/                    |
| startpage | misc     | Custom browser start page                                 |
| archlinux | system   | Arch Linux: bash, zsh, git, X11, Wayland flags, XDG       |
| mac       | system   | macOS: minimal zshrc                                      |

## Profile

A **profile** is a JSON file (`profiles/<name>.json`) that declares which modules to deploy on a particular machine. Each profile lists enabled modules under `apps`, `desktop`, `misc`, and `system` keys.

## Bootstrap

The **bootstrap** process reads a profile, validates the environment, creates symlinks with conflict detection, and verifies the result. Replaces GNU Stow with a validated symlink farm.

## Validated Symlink Farm

A **validated symlink farm** replaces `stow -R` with direct `ln -s` calls, guarded by:

1. Pre-validation: check source paths exist, target parents exist
2. Conflict detection: skip or warn when target already exists and isn't a symlink
3. Post-validation: symlinks resolve, configs parse, scripts are executable, secrets decrypt

## Autostart

The **autostart** script (`~/.local/script/autostart`) launches shared applications when any WM starts. WM-specific startup items stay in each WM's config. The autostart script handles ordering: apps that depend on earlier services (e.g., brave needs noctalia's notification daemon) wait for a readiness check before launching.

## Controller

The **controller** script (`~/.local/script/controller`) provides a unified interface for actions bound to keyboard shortcuts across all WMs. Subcommands:

- `controller volume up|down|mute` — audio control
- `controller brightness up|down` — screen brightness
- `controller kbdlight up|down` — keyboard backlight
- `controller player play|pause|next|prev` — media player control
- `controller app terminal|browser|filemanager|chat` — launch common apps
- `controller noctalia launcher|clipboard|emoji` — Noctalia shell IPC actions

WM binds files become thin adapters that call `controller <action>`.

## Keybinding Convention

A **keybinding convention** is a markdown document (`docs/keybindings.md`) listing the standard key-to-action mapping across mangoWM, niri, and Hyprland. Covers: window management, workspace/tag navigation, monitor/screen, app launching, media control, system controls, noctalia shell, and screenshots. Each WM's binds file follows the same keys for the same actions. A **deviance log** records intentional departures with reasons. Enforced by review, not mechanically.

## Secrets Loading

**Secrets loading** decrypts `~/.config/fish/secrets.yaml` (SOPS/age) and exports values as environment variables. There are two implementations:

- `secrets.sh` — POSIX sh script sourceable by bash and zsh. Sourced from `.profile` at login.
- `secrets.fish` — Fish wrapper that invokes a bash subprocess, sources `secrets.sh`, then re-exports the resulting env vars.

See `docs/secrets.md` for the full setup guide.

## Script Conventions

All scripts under `~/.local/script/` follow a **script convention** — a set of rules ensuring every script is self-contained, copy-pasteable, and predictable. The conventions cover shebangs, error handling (`set -euo pipefail`), argument parsing (`while`/`case`), logging (`info`/`ok`/`warn`/`err`), and cleanup (`trap`). See `docs/script-style.md` for the full specification.

The **template** (`template.sh`) is the scaffold for new scripts. Copy it, fill in the sections, and the convention is satisfied by construction.

## Dependencies

- `jq` — required for profile parsing during bootstrap
- `age` / `rage` — required for secrets decryption
- `sops` — required for secrets decryption
