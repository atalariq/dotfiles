# Dotfiles Conceptual Glossary

## Module

A **module** is the unit of deployment. It lives under `config/<category>/<name>/` where category is one of `app`, `desktop`, `misc`, or `system`. Files inside a module mirror their intended target path under `$HOME` — so `config/app/fish/.config/fish/config.fish` links to `~/.config/fish/config.fish`.

Modules are addressed as `<category>/<name>` in CLI commands (e.g. `app/fish`, `desktop/mango`).

## Profile

A **profile** is a `profiles/<name>.json` file with a flat `modules` array declaring which modules to deploy together on a machine. Example:

```json
{
  "name": "laptop",
  "modules": ["app/fish", "app/kitty", "desktop/mango", "system/archlinux"]
}
```

## Bootstrap

**Bootstrap** is the deploy system (`./setup.sh` at repo root, a shim over `script/bootstrap.sh`). It reads a profile or a single module path, creates per-file symlinks under `$HOME`, detects conflicts, and validates results. It replaces GNU Stow with an explicit, validated process.

## Validated Symlink Farm

On each deploy, bootstrap enforces a validation pipeline:

1. Pre-check: source paths exist; target parent directories exist
2. Conflict detection: warn (or interactively resolve) when a target already exists and is not the expected symlink
3. Post-validation: symlinks resolve correctly; Fish config parses without error; JSON is well-formed; SOPS secrets decrypt; scripts have executable bits set

Default linking is file-by-file. This keeps unrelated files in the same directory independent.

## Directory Folding

When a module's target directory does not yet exist in `$HOME`, bootstrap may link the entire subtree as a single directory symlink instead of per-file links. This is conservative: it only applies when the target directory is absent. Modules can force this behavior via a `.bootstrap.json` `directory_links` declaration (e.g. `misc/scripts` uses this for `~/.local/script/`).

## Autostart

`config/desktop/*/` modules may include autostart scripts that launch shared applications when a window manager or Wayland session starts. WM-specific startup items live in each WM's own config; the autostart layer handles ordering and readiness checks for shared services.

## Theming

`../wana` is the ratified palette and single source of truth. `wana/tools/gen.py`
renders per-app theme files; `script/theme-sync` vendors them into module paths
(committed, no runtime dependency); `theme-switch {dark|light|toggle}` repoints
per-app `current` symlinks and nudges live apps. pywal and matugen remain
opt-in dynamic modes and never overwrite the vendored wana themes.

Targets covered by the wana pipeline: kitty, alacritty, TTY, pywal, fzf, bat, delta, btop, lazygit, opencode, starship, tmux, herdr. Noctalia templating covers desktop GUI apps and yazi. nvim (everforest), yazi-flavor, and atuin are intentionally not wana-generated (see the A2 spec).

The `app/tmux` module is the primary multiplexer (TTY/SSH/server, plugin-free); herdr is the desktop-GUI multiplexer. Both are wana theme targets — tmux via a Class A symlink, herdr via a Class C in-place block.

## Controller

A **controller** is a module that manages or coordinates other modules. Currently rare; most modules are self-contained.

## Secrets Loading

`secrets/` contains a SOPS/age-encrypted `secrets.yaml` and a POSIX `load.sh` loader. Bootstrap links them to `~/.config/sops/` and `~/.local/script/` respectively. `.profile` sources `load.sh` at login to export decrypted values as environment variables. Fish gets a thin wrapper that invokes a bash subprocess to re-export those values into the Fish environment.

See `docs/secrets.md` for the full setup guide.

## Script Conventions

Shell scripts under `config/misc/scripts/` (deployed to `~/.local/script/`) follow a shared style: POSIX-compatible shebangs, `set -euo pipefail`, `while`/`case` argument parsing, consistent `info`/`ok`/`warn`/`err` logging helpers, and `trap` cleanup. See `docs/script-style.md`.

---

The module inventory is NOT maintained here. Source of truth: `config/<category>/<module>` on disk + `profiles/*.json`.
