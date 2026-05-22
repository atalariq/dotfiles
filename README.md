# dotfiles

Configuration files managed via a validated symlink farm.

## Setup

```bash
# Clone
git clone git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles

# Deploy (requires jq)
cd ~/Repos/dotfiles
./setup.sh laptop
```

`setup.sh` delegates to `bootstrap.sh`, which reads a JSON profile and creates symlinks under `$HOME`.

### Profiles

Machine-specific JSON profiles live in `profiles/`. Each declares which modules to deploy:

```json
{
  "name": "laptop",
  "apps": ["kitty", "fish", "yazi", "zed", "zellij"],
  "desktop": ["mango", "noctalia"],
  "misc": ["fonts", "scripts"],
  "system": "archlinux"
}
```

| Profile       | For                           |
| ------------- | ----------------------------- |
| `laptop.json` | Personal laptop (full)        |
| `lab.json`    | Lab machine (minimal: bat, fish, yazi) |

You can also deploy a single module directly:

```bash
./setup.sh use app/fish
./setup.sh undo app/kitty
```

Or pass a custom JSON config:

```bash
./setup.sh path/to/my-machine.json
```

### Bootstrapping a fresh machine

```bash
# Install essentials (Arch)
sudo pacman -S git jq stow

# Deploy dotfiles
git clone git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
./setup.sh laptop
```

## Tech stack

| Layer             | Primary           | Alternative       |
| ----------------- | ----------------- | ----------------- |
| OS                | Arch Linux        | macOS             |
| WM                | mangoWM           | niri              |
| Desktop shell     | Noctalia          | —                 |
| Terminal          | kitty             |                    |
| Shell (login)     | bash              | zsh               |
| Shell (interactive) | fish           |                    |
| Multiplexer       | zellij            | —                 |
| Editor            | Zed               | Neovim            |
| File manager      | yazi (TUI)        | Nautilus (GUI)    |
| Launcher          | noctalia-shell    |                   |
| Media             | mpv               | mpd/ncmpcpp       |
| Git TUI           | lazygit           |                   |
| Screenshots       | grimblast         |                   |
| Clipboard         | cliphist + wl-clipboard |              |
| Theming           | Noctalia + pywal  |                   |
| Secrets           | SOPS + age        |                   |

## Architecture

| Script                  | Role                                        |
| ----------------------- | ------------------------------------------- |
| `bootstrap.sh`          | Validated symlink farm (use/profile/undo)   |
| `setup.sh`              | Thin wrapper around bootstrap.sh            |
| `autostart`             | Shared app launcher for all WMs             |
| `controller`            | Unified keybind actions (volume, brightness, media, apps, noctalia) |

| Doc                         | Covers                                          |
| --------------------------- | ----------------------------------------------- |
| `CONTEXT.md`                | Domain glossary                                 |
| `docs/adr/`                 | Architecture decision records                   |
| `docs/keybindings.md`        | Standard key mappings across WMs                |
| `docs/script-style.md`       | Conventions for writing shell scripts           |
| `docs/secrets.md`            | SOPS/age secrets setup guide                    |
| `docs/agents/`               | Agent skill configuration (issue tracker, labels, domain docs) |

## Dependencies

### Required
- `jq` — JSON profile parsing
- `bash` — bootstrap and scripts

### Optional
- `age` / `rage` — secrets decryption
- `sops` — secrets file management
- `fish` — interactive shell (config deployed but bash/zsh work without it)
