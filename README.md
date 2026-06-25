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

`setup.sh` (repo root) is a shim that forwards to `script/setup.sh`, which delegates to `script/bootstrap.sh`. The bootstrap script reads a profile, links files into `$HOME`, detects conflicts, and validates the result.

Default behavior is file-level symlinking. Modules can opt into scoped directory-level symlinks through module metadata when a subtree is intentionally managed as one unit. `misc/scripts` uses that for `~/.local/script`.

## Repo layout

Deployable modules now live under `config/`:

```text
config/
  app/
  desktop/
  misc/
  system/
profiles/
script/
secrets/
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

| Profile       | For                                      |
| ------------- | ---------------------------------------- |
| `laptop.json` | Personal laptop (full)                   |
| `lab.json`    | Lab machine (minimal shell/editor tools) |

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
git sparse-checkout set config/app/fish profiles script/setup.sh script/bootstrap.sh setup.sh README.md
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

AI tool configs are backed up under `config/app/ai-tools/`.

## Theming

- **Theming:** wana palette → `theme-switch dark|light|toggle`; regenerate with `script/theme-sync`.

## Tech stack

| Layer               | Primary                               | Alternative    |
| ------------------- | ------------------------------------- | -------------- |
| OS                  | Arch Linux                            | macOS          |
| WM                  | mangoWM                               | niri           |
| Desktop shell       | Noctalia                              | —              |
| Terminal            | kitty                                 | —              |
| Shell (login)       | bash                                  | zsh            |
| Shell (interactive) | fish                                  | —              |
| Multiplexer         | herdr                                 | —              |
| Editor              | Neovim                                | —              |
| File manager        | yazi (TUI)                            | Nautilus (GUI) |
| Launcher            | noctalia-shell                        | —              |
| Media               | mpv                                   | mpd/ncmpcpp    |
| Git TUI             | lazygit                               | —              |
| Screenshots         | grimblast                             | —              |
| Clipboard           | cliphist + wl-clipboard               | —              |
| Theming             | wana palette (pywal/matugen optional) | —              |
| Secrets             | SOPS + age                            | —              |

## Architecture

| Script                                         | Role                                                |
| ---------------------------------------------- | --------------------------------------------------- |
| `script/bootstrap.sh`                          | Validated symlink farm (`use` / `profile` / `undo`) |
| `script/setup.sh`                              | Entry point: parses args, delegates to bootstrap    |
| `setup.sh`                                     | Repo-root shim → forwards to `script/setup.sh`      |
| `secrets/`                                     | SOPS/age encrypted secrets + POSIX loader           |
| `config/misc/scripts/.local/script/autostart`  | Shared app launcher for all WMs                     |
| `config/misc/scripts/.local/script/controller` | Unified keybind actions                             |

| Doc                       | Covers                                |
| ------------------------- | ------------------------------------- |
| `CONTEXT.md`              | Domain glossary                       |
| `AGENTS.md`               | Agent and contributor guide           |
| `docs/script-style.md`    | Conventions for writing shell scripts |
| `docs/secrets.md`         | SOPS/age secrets setup guide          |
| `docs/install-package.md` | Package and tool installation guide   |

## Dependencies

### Required

- `bash` — bootstrap and scripts
- `python3` — profile parsing and JSON validation during bootstrap

### Optional

- `fish` — interactive shell config
- `sops` — secrets management
- `age` / `rage` — secrets key management
