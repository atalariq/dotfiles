# AGENTS.md — Dotfiles Repo Guide

Primary reference for AI agents and humans working in this repo. For concept definitions, see `CONTEXT.md`.

---

## Repo Layout

```text
config/
  app/          # Application configs (kitty, fish, nvim, yazi, …)
  desktop/      # WM/compositor configs (mango, niri, wal, …)
  misc/         # Scripts, fonts, browser startpage
  system/       # OS-level config (archlinux, mac)
profiles/       # Machine profiles (*.json)
script/
  bootstrap.sh  # Validated symlink farm (core deploy logic)
  setup.sh      # Entry point: parses args, delegates to bootstrap.sh
setup.sh        # Repo-root shim → forwards to script/setup.sh
secrets/        # SOPS/age encrypted secrets + POSIX loader
docs/           # Documentation (secrets.md, script-style.md, install-package.md)
```

---

## How to Add a Module

1. Create `config/<category>/<name>/` with files mirroring their `$HOME` target paths
2. Add the module to relevant `profiles/*.json`
3. Preview: `./setup.sh --dry-run use <category>/<name>`
4. Deploy: `./setup.sh use <category>/<name>`

---

## How to Move a Module

1. `git mv config/<old-category>/<old-name> config/<new-category>/<new-name>`
2. Update all `profiles/*.json` references
3. `./setup.sh undo <old-category>/<old-name>; ./setup.sh use <new-category>/<new-name>`
   (or `./setup.sh restow <new-category>/<new-name>` if only renamed within same path)

---

## How to Retire a Module

1. `./setup.sh undo <category>/<module>` — remove symlinks from `$HOME`
2. `git rm -r config/<category>/<module>/`
3. Remove from all `profiles/*.json`

---

## Deployment Commands

```bash
./setup.sh profile <name>               # Deploy a whole profile
./setup.sh use <category>/<module>      # Deploy a single module
./setup.sh undo <category>/<module>     # Remove a module's symlinks
./setup.sh restow <category>/<module>   # Re-link (undo + use)
./setup.sh adopt <category>/<module>    # Pull existing $HOME files into repo
./setup.sh secrets                      # Link secrets/ to ~/.config/sops/ and ~/.local/script/
./setup.sh undo profile <name>          # Roll back an entire profile
./setup.sh --dry-run ...                # Preview actions without touching files
./setup.sh --force ...                  # Non-interactive (auto-overwrite conflicts)
```

---

## Secrets Workflow

See `docs/secrets.md`. Short version:

```bash
sops secrets/secrets.yaml              # Edit secrets
sops updatekeys secrets/secrets.yaml   # Rotate keys
./setup.sh secrets                     # Deploy (link to ~/.config/sops/ and ~/.local/script/)
```

---

## Commit Conventions

Conventional Commits: `<type>(<scope>): <description>`

Examples: `feat(nvim):`, `refactor(fish):`, `fix(bootstrap):`, `docs:`, `chore:`

Append when AI-assisted:

```
Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

---

## Standing Rule

**On any significant change — new module, moved/retired module, new command, changed layout — update `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, and `README.md` (if user-facing).**

---

If AGENTS.md grows too large, split detailed topics into separate files under `docs/` and link from here.
