# ADR-0002: Merge Neovim configs into dotfiles

Status: Accepted

## Context

Neovim used to live in a separate `nvim-config` repo while the rest of the machine config lived in `dotfiles`. That split made the Fish profile helper, repo docs, and actual deployed config drift apart. The separate repo also had stale profile names that no longer matched what is actually used day to day.

## Decision

Move the Neovim setup into `dotfiles` as a first-class module under `app/nvim/.config/`.

Keep only the real `NVIM_APPNAME` profiles that are still used:

- `nvim` for the main config
- `nvim-minimal` for the fallback/minimal profile

Retire stale profile references instead of preserving them for historical curiosity. In particular, ignore the old `nvim-k`, `nvim-lazyvim`, and `nvim-minimax` aliases because they do not reflect the active setup.

## Consequences

- `dotfiles` becomes the single place to maintain shell + editor config.
- Fish helpers stay aligned with the actual deployed Neovim profiles.
- Documentation can point at one repo and one module path instead of two separate sources.
- The old `nvim-config` repo can be treated as archived reference material rather than an active source of truth.
