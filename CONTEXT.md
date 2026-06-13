# Dotfiles Domain Glossary

## Modules

A **module** is a deployable config directory rooted under `config/`. Each module is self-contained and can be deployed or skipped independently.

CLI examples still use `<category>/<module>`:
- `app/fish`
- `desktop/mango`
- `misc/scripts`
- `system/archlinux`

Those resolve to real paths like `config/app/fish` and `config/system/archlinux`.

| Module | Category | Description |
| --- | --- | --- |
| kitty | app | Terminal emulator config + themes |
| fish | app | Fish shell: config, conf.d/, functions/, completions/ |
| yazi | app | TUI file manager with plugins and flavors |
| zed | app | Text editor: settings, keymaps, themes |
| nvim | app | Neovim config + `NVIM_APPNAME` profiles (`nvim`, `nvim-minimal`) |
| mpd | app | Music Player Daemon + ncmpcpp + rmpc clients |
| mpv | app | Video player: config, keybinds, scripts |
| imv | app | Image viewer |
| aria2 | app | Download manager |
| yt-dlp | app | YouTube/media downloader |
| lazygit | app | Git TUI |
| espanso | app | Text expander (disabled by default) |
| mango | desktop | mangoWM Wayland compositor config |
| niri | desktop | niri scrollable-tiling Wayland compositor config |
| hyprland | desktop | Hyprland WM (legacy, disabled) |
| wal | desktop | pywal color scheme system |
| fonts | misc | Custom fonts + fontconfig |
| scripts | misc | Utility scripts under `~/.local/script/` (deployed as one declared directory symlink) |
| startpage | misc | Custom browser start page |
| archlinux | system | Arch Linux: bash, zsh, git, X11, Wayland flags, XDG |
| mac | system | macOS: minimal zshrc |


## Profile

A **profile** is a JSON file (`profiles/<name>.json`) that declares which modules to deploy on a machine. Profiles now use one flat `modules` array instead of separate `apps`, `desktop`, `misc`, and `system` keys.

Example:

```json
{
  "name": "lab",
  "modules": [
    "app/fish",
    "app/yazi"
  ]
}
```

## Bootstrap

The **bootstrap** process reads a profile, validates the environment, creates symlinks with conflict detection, and verifies the result. It replaces GNU Stow with a validated symlink farm.

## Validated Symlink Farm

A **validated symlink farm** replaces `stow -R` with direct `ln -s` calls, guarded by:

1. Pre-validation: check source paths exist, target parents exist
2. Conflict detection: skip or warn when target already exists and is not the same symlink
3. Post-validation: symlinks resolve, configs parse, scripts are executable, secrets decrypt

Default deployment is file-by-file. Modules can declare specific directory-level symlinks for subtrees that are intentionally managed as one unit. `misc/scripts` uses that escape hatch for `~/.local/script`.

## Autostart

The **autostart** script (`~/.local/script/autostart`) launches shared applications when any WM starts. WM-specific startup items stay in each WM's config. The autostart script handles ordering: apps that depend on earlier services wait for readiness checks before launching.

Source path in repo: `config/misc/scripts/.local/script/autostart`.

## Controller

The **controller** script (`~/.local/script/controller`) provides a unified interface for actions bound to keyboard shortcuts across all WMs.

Subcommands:
- `controller volume up|down|mute` — audio control
- `controller brightness up|down` — screen brightness
- `controller kbdlight up|down` — keyboard backlight
- `controller player play|pause|next|prev` — media player control
- `controller app terminal|browser|filemanager|chat` — launch common apps
- `controller noctalia launcher|clipboard|emoji` — Noctalia shell IPC actions

WM bind files become thin adapters that call `controller <action>`.

## Keybinding Convention

A **keybinding convention** is a markdown document (`docs/keybindings.md`) listing the standard key-to-action mapping across mangoWM, niri, and Hyprland. It covers window management, workspace/tag navigation, monitor/screen, app launching, media control, system controls, Noctalia shell, and screenshots.

## Secrets Loading

**Secrets loading** decrypts `~/.config/fish/secrets.yaml` (SOPS/age) and exports values as environment variables.

There are two implementations:
- `secrets.sh` — POSIX sh script sourceable by bash and zsh. Sourced from `.profile` at login.
- `secrets.fish` — Fish wrapper that invokes a bash subprocess, sources `secrets.sh`, then re-exports the resulting env vars.

See `docs/secrets.md` for the full setup guide.

## Script Conventions

All scripts under `~/.local/script/` follow a **script convention** so they stay self-contained, copy-pasteable, and predictable. The conventions cover shebangs, error handling (`set -euo pipefail`), argument parsing (`while`/`case`), logging (`info`/`ok`/`warn`/`err`), and cleanup (`trap`). See `docs/script-style.md`.

The **template** (`template.sh`) is the scaffold for new scripts. Copy it, fill in the sections, and the convention is satisfied by construction.

## Dependencies

- `bash` — required for bootstrap and general scripts
- `python3` — required for profile parsing and JSON validation during bootstrap
- `age` / `rage` — required for secrets decryption
- `sops` — required for secrets decryption
