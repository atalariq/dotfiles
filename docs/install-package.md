# Package Installation Guide

This page is the install/reference doc for development packages used across the dotfiles and editor setup.

Goal: keep package installation understandable and reproducible without pretending one giant command is always the right answer.

## Install philosophy

- Prefer built-in package managers first.
- Keep the base machine small, then add language- or tool-specific extras as needed.
- AUR packages are optional, not assumed.
- This doc is a reference, not a blind one-shot bootstrap script.

## Minimal base for this repo

```bash
sudo pacman -Syu
sudo pacman -S --needed \
  git bash python fish neovim fzf bat \
  uv mise go rustup
```

That is enough for bootstrap plus the common language toolchains.

## Recommended core dev tooling

Bias this toward the stack that actually matters day-to-day: Go, web, SQL, containers, docs, and dotfiles.

```bash
sudo pacman -S --needed \
  just pixi \
  shfmt shellcheck prettier \
  stylua typos yamllint
```

## Secondary / coursework / experiment tooling

Install these when you actually need them, not by reflex:

```bash
sudo pacman -S --needed \
  php kotlin
```

## LSPs

```bash
sudo pacman -S --needed \
  bash-language-server lua-language-server clang \
  systemd-lsp \
  yaml-language-server dockerfile-language-server gitlab-ci-ls just-lsp \
  texlab tinymist marksman \
  eslint-language-server tailwindcss-language-server \
  vscode-html-languageserver vscode-css-languageserver vscode-json-languageserver
```

Optional / AUR / ecosystem-specific:

```bash
yay -S --needed \
  jdtls kotlin-lsp-bin \
  basedpyright-bin phpactor-bin \
  postgres-language-server-bin sqls-bin \
  vtsls
```

Notes:
- Skip `gopls` here if you already install it through Go (`go install golang.org/x/tools/gopls@latest`).
- Skip `rust-analyzer` here if you want to rely on `rustup component add rust-analyzer` instead.
- Current Neovim config uses `postgres_lsp` as the main SQL server and keeps `sqls` as optional fallback, not a second always-on default.
- `tombi` replaces `taplo` in this setup.
- Arch's `dockerfile-language-server` package currently exposes the `docker-langserver` binary. That is the command Neovim checks for.

## Formatters and linters

```bash
sudo pacman -S --needed \
  gofumpt pgformatter biome yamlfmt \
  typstyle ktlint golangci-lint python-ruff \
  selene sqlfluff
```

Optional / AUR:

```bash
yay -S --needed \
  google-java-format hadolint-bin detekt-cli
```

## Debuggers

```bash
sudo pacman -S --needed \
  delve python-debugpy lldb xdebug
```

## Current Neovim plugin runtime deps

These are not generic system packages. They matter because the current `config/app/nvim` setup actually calls them.

```bash
sudo pacman -S --needed \
  deno websocat
```

Why:
- `peek.nvim` builds with `deno`
- `typst-preview.nvim` expects `tinymist` and `websocat`

## Language ecosystems

### Rust

```bash
rustup default stable
cargo install iwe iwes
```

### Node / JS

Corepack is assumed. Enable it once:

```bash
corepack enable
```

### Python

Use `uv` for isolated installs and project envs. Avoid random global `pip install` on this machine.

## AI / agent tooling

Package names and install method can drift, so keep the exact current setup in [`docs/ai-tools.md`](./ai-tools.md).

That doc covers:
- Hermes Agent
- OpenCode
- Codex CLI
- Zed integration

For backup/safety-net purposes, this repo now also carries curated config snapshots for:
- `config/app/ai-tools/.config/opencode/`
- `config/app/ai-tools/.codex/`

Important: Neovim currently does **not** have an AI plugin wired in. AI tooling today lives in CLI workflows plus Zed agent integration. That is probably the right default for now unless a Neovim-side tool proves it adds signal instead of friction.

## Post-install verification

Run whatever applies to the stack you actually installed:

```bash
bash --version
python3 --version
uv --version
mise --version
go version
rustup --version
lua-language-server --version
stylua --version
ruff --version
shellcheck --version
shfmt --version
prettier --version
```

Optional checks:

```bash
just --version
tinymist --version
marksman --version
delve version
```

## What is intentionally not automated

- Full package installation for every machine persona
- AUR bootstrap policy
- GPU / Android / Java heavy toolchains by default
- Per-project language tools that only matter in one repo

That stuff changes too often. Better as docs and conscious installs than magic that rots.
