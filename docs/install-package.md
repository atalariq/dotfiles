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
  git bash python fish \
  uv mise go rustup
```

That is enough for bootstrap plus the common language toolchains.

## Recommended core dev tooling

```bash
sudo pacman -S --needed \
  just pixi php kotlin \
  shfmt shellcheck prettier \
  stylua typos yamllint
```

## LSPs

```bash
sudo pacman -S --needed \
  bash-language-server lua-language-server systemd-lsp \
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
  google-java-format hadolint-bin detekt-bin
```

## Debuggers

```bash
sudo pacman -S --needed \
  delve python-debugpy lldb xdebug
```

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
- Gemini CLI
- Zed integration

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
