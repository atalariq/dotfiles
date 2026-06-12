# dotfiles

Personal dotfiles managed with a validated symlink farm.

## Setup

```bash
# Clone
git clone git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles

# Deploy a full profile
cd ~/Repos/dotfiles
./setup.sh laptop
```

`setup.sh` is a thin wrapper around `bootstrap.sh`. The bootstrap script reads a profile, links files into `$HOME`, detects conflicts, and validates the result.

## Repo layout

Deployable modules now live under `config/`:

```text
config/
  app/
  desktop/
  misc/
  system/
profiles/
docs/
```

A module is still addressed as `<category>/<module>` in the CLI:

```bash
./setup.sh use app/fish
./setup.sh undo app/kitty
```

Internally those resolve to `config/app/fish` and `config/app/kitty`.

## Profiles

Machine-specific JSON profiles live in `profiles/`. Each profile declares deployable modules with a flat `modules` array:

```json
{
  "name": "laptop",
  "modules": [
    "app/kitty",
    "app/fish",
    "desktop/mango",
    "misc/scripts",
    "system/archlinux"
  ]
}
```

| Profile | For |
| --- | --- |
| `laptop.json` | Personal laptop (full) |
| `lab.json` | Lab machine (minimal shell/editor tools) |

You can also pass a custom JSON config:

```bash
./setup.sh path/to/my-machine.json
```

## Bootstrapping a fresh machine

```bash
# Install essentials (Arch)
sudo pacman -S git python fish

# Deploy dotfiles
git clone git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
./setup.sh laptop
```

## Download only what you need

GitHub does not support "clone just one folder" directly. If you want a subset, use sparse checkout.

### Sparse checkout for one module

```bash
git clone --filter=blob:none --no-checkout git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
git sparse-checkout init --cone
git sparse-checkout set config/app/fish profiles bootstrap.sh setup.sh README.md
git checkout main
```

That is the sane option when a module depends on multiple files.

### Single-file grab

```bash
mkdir -p ~/.config/fish
curl -fsSL https://raw.githubusercontent.com/atalariq/dotfiles/main/config/app/fish/.config/fish/config.fish \
  -o ~/.config/fish/config.fish
```

Use this only for truly standalone files. It is a bad fit for modules like Fish, Neovim, Yazi, or Noctalia that span multiple files.

## Neovim

The `app/nvim` module lives in this repo at `config/app/nvim` and owns two `NVIM_APPNAME` trees:
- `nvim` for the main config
- `nvim-minimal` for the fallback profile

The Fish helper at `config/app/fish/.config/fish/conf.d/40-nvim.fish` exposes the selector and aliases for those real profiles only.

## AI tooling

Current AI/dev-agent setup is documented in [`docs/ai-tools.md`](docs/ai-tools.md).

That page covers:
- Hermes Agent
- OpenCode
- Codex CLI
- Gemini CLI
- Zed agent integration

## Tech stack

| Layer | Primary | Alternative |
| --- | --- | --- |
| OS | Arch Linux | macOS |
| WM | mangoWM | niri |
| Desktop shell | Noctalia | — |
| Terminal | kitty | — |
| Shell (login) | bash | zsh |
| Shell (interactive) | fish | — |
| Multiplexer | zellij | — |
| Editor | Zed | Neovim |
| File manager | yazi (TUI) | Nautilus (GUI) |
| Launcher | noctalia-shell | — |
| Media | mpv | mpd/ncmpcpp |
| Git TUI | lazygit | — |
| Screenshots | grimblast | — |
| Clipboard | cliphist + wl-clipboard | — |
| Theming | Noctalia + pywal | — |
| Secrets | SOPS + age | — |

## Architecture

| Script | Role |
| --- | --- |
| `bootstrap.sh` | Validated symlink farm (`use` / `profile` / `undo`) |
| `setup.sh` | Thin wrapper around `bootstrap.sh` |
| `config/misc/scripts/.local/script/autostart` | Shared app launcher for all WMs |
| `config/misc/scripts/.local/script/controller` | Unified keybind actions |

| Doc | Covers |
| --- | --- |
| `CONTEXT.md` | Domain glossary |
| `docs/adr/` | Architecture decision records |
| `docs/keybindings.md` | Standard key mappings across WMs |
| `docs/script-style.md` | Conventions for writing shell scripts |
| `docs/secrets.md` | SOPS/age secrets setup guide |
| `docs/install-package.md` | Package and tool installation guide |
| `docs/ai-tools.md` | AI CLI and editor agent setup |
| `docs/agents/` | Agent skill configuration |

## Dependencies

### Required
- `bash` — bootstrap and scripts
- `python3` — profile parsing and JSON validation during bootstrap

### Optional
- `fish` — interactive shell config
- `sops` — secrets management
- `age` / `rage` — secrets key management
