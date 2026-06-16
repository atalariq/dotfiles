# Dotfiles Cleanup, Refactor & Docs Overhaul — Design

**Date:** 2026-06-17
**Goal:** Finish all in-flight work, complete half-done refactors, relocate
secrets, overhaul the context docs, and end with a clean working tree pushed to
`origin/main` as granular chronological commits.
**Scope decision:** do everything in one (long) session.

## Context

The working tree carries a large module reorganization plus several incomplete
refactors. This spec finishes that work and layers on newly requested changes:
secrets relocation, a docs overhaul, a compact package list, and moving the
deploy scripts into `script/`.

## Confirmed Decisions

| Area             | Decision                                                                                                                                                             |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bootstrap        | Improve current script; move `bootstrap.sh`/`setup.sh` into `script/`                                                                                                |
| Yazi             | Full minimalist; **delete** `docs/yazi.md` (no rewrite)                                                                                                              |
| Neovim           | Bug-fixes only + selene/lua_ls `vim`-global fix + `cd to project root` keymap. No new plugins.                                                                       |
| Commit dates     | Backdate each commit to the module's latest file mtime                                                                                                               |
| ai-tools         | Back up the config; add narrow `.gitignore` for runtime noise                                                                                                        |
| obs-studio / imv | Commit obs config only (exclude logs/profiler_data); retire imv                                                                                                      |
| Secrets          | Root `secrets/` folder + bootstrap special-case deploy                                                                                                               |
| Context docs     | Keep only **CONTEXT.md + AGENTS.md + CLAUDE.md**; remove `docs/adr/`, `docs/agents/`; rewrite from scratch; add an "update context files on significant change" rule |
| Removed docs     | `docs/yazi.md`, `docs/keybindings.md`, `docs/ai-tools.md`                                                                                                            |
| install-package  | Rewrite compact from actual installed packages (`pacman -Qqen` / `-Qqem`)                                                                                            |

---

## Area A — Neovim (bug-fixes + targeted additions)

### A1. Crash fix — undefined `LazyVim` global

`lua/plugins/lint.lua:80` calls `LazyVim.warn(...)` (LazyVim leftover); throws
when a configured linter is missing.
**Fix:** `vim.notify("Linter not found: " .. name, vim.log.levels.WARN)`.

### A2. `vim` flagged as undefined global — root cause

The culprit is **selene**, not lua_ls, not the symlink. `lint.lua:24` runs
`selene` for lua; `selene.toml` defines no `std`, so selene uses plain Lua's
stdlib and flags every `vim.*`. The LazyVim `selene.toml` + `vim.yml` std were
lost in the migration. `selene.toml` is correctly found via upward search from
the symlinked buffer path.
**Fix:**

1. Add `config/app/nvim/.config/nvim/vim.yml`:
   ```yaml
   ---
   base: lua51
   globals:
     vim:
       any: true
   ```
2. Set `std = "vim"` in `selene.toml` (keep existing `[lints]` allows).

### A3. New keymap — cd to project root

`<leader>cd` → cd to project root via
`vim.fs.root(0, { ".git", ".hg", ".svn", "Makefile", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", ".luarc.json" })`,
falling back to the file's directory; notify the new cwd.

**Out of scope:** comment-toggle, notify.nvim, mini.diff, sessions,
todo-comments, inlay-hints auto, format-on-save expansion.

---

## Area B — Yazi (full minimalist)

`package.toml` is already empty; remove the remaining dead references.

1. `keymap.toml` — remove orphan binds (`Z`/`z` lines 15-16; `g D`/`g m`/`g P`/
   `g M`/`c m` and the "Core/Optional" sections lines 38-50).
2. `init.lua` — delete commented setup blocks (lines 1-38); keep symlink +
   user/group statusbar additions.
3. `yazi.toml` — delete commented `[plugin]` block (lines 38-59).
4. **Delete `docs/yazi.md`.**

**Verify:** yazi launches with no config/keymap errors.

---

## Area C — ai-tools (back up config + ignore noise)

No secrets present (verified). User wants these backed up.

1. Commit untracked config: `.claude/{CLAUDE.md,RTK.md,settings.json,statusline-command.sh}`,
   `.config/rtk/config.toml`, `.config/tirith/gateway.yaml`, `.tirith/policy.yaml`.
2. Stage existing deletion of `.config/opencode/package.json`.
3. Add a narrow `.gitignore` in the ai-tools module to keep runtime noise out
   (session dirs, `*.db`, `*.log`, history). Exact globs validated against what
   each tool writes at implementation time.
4. If quick: remove empty `.codex/hooks.json`; note `RTK.md` duplication.

**Verify:** `git status` shows only intended config staged; no `*.db`/`*.log`/
session dirs tracked.

---

## Area D — Bootstrap (improve + relocate)

### D1. Relocate scripts to `script/`

Move `bootstrap.sh` + `setup.sh` → `script/`. Fix `DOTFILES_DIR` derivation
(add `/..`). Add a thin root `setup.sh` shim that forwards to
`script/setup.sh` so `./setup.sh laptop` still works. Update README/docs paths.

### D2. Ergonomic improvements

1. **Auto directory-folding heuristic** — fold a module subtree into one dir
   symlink when its target directory does not yet exist; keep `directory_links`
   escape hatch for forced folding.
2. **`restow <category/module>`** — idempotent re-link (undo + use).
3. **`adopt <category/module>`** — move existing `$HOME` files into the repo,
   then link.
4. **`undo profile <name>`** — roll back every module in a profile
   (bidirectional counterpart to `profile`).
5. **`--dry-run`** — print planned actions, touch nothing.
6. **`--force`** — non-interactive conflict resolution (auto-overwrite).
7. **Simpler CLI** — `setup.sh` infers command from arg (`setup app/fish`).

### D3. Secrets deploy hook

Add bootstrap handling for the root `secrets/` folder (see Area E).

**Verify:** `--dry-run profile lab`; `use`/`restow`/`undo` round-trip on a
throwaway module; `undo profile` on a 2-module test profile.

---

## Area E — Secrets relocation (root `secrets/`)

Decouple secrets from fish. Current: encrypted store + loaders live under
`config/app/fish/.config/fish/`. `.profile` (bash/zsh) and fish both depend on
them.

**New layout — repo root `secrets/`:**

```
secrets/
  secrets.yaml      # SOPS/age encrypted store (source of truth)
  load.sh           # POSIX loader (sourced by .profile; shell-agnostic)
```

**Deploy targets (via bootstrap special-case):**

- `secrets/secrets.yaml` → `~/.config/sops/secrets.yaml`
- `secrets/load.sh` → `~/.local/script/secrets-load` (executable)

**Wiring:**

- `.profile` sources `~/.local/script/secrets-load` (bash/zsh login).
- Fish `conf.d/90-secrets.fish` becomes a thin wrapper that calls the same
  loader (drop the duplicated decrypt logic; keep `load_secrets`/`unload_secrets`/
  `secrets-status` UX but point at the shared store path).
- Remove `config/app/fish/.config/fish/secrets.yaml` and
  `conf.d/secrets.sh` (moved to `secrets/`).
- `.sops.yaml` regex `.*secrets\.yaml$` already matches the new path; verify.

**Docs:** update `docs/secrets.md` for the new locations + flow.

**Verify:** `sops -d secrets/secrets.yaml` works; a fresh bash login and a fish
session both load the vars; `.sops.yaml` still encrypts on save.

---

## Area F — install-package.md (compact rewrite)

Rewrite as a compact, reproducible reference generated from this machine:

- Native explicit: `pacman -Qqen` (226 pkgs) → one `pacman -S --needed` block.
- AUR/foreign explicit: `pacman -Qqem` (45 pkgs) → one `yay -S --needed` block.

Keep a short "philosophy" header and a minimal-base callout; drop the long prose
sections. Lightly group if cheap, but the explicit lists are the source of
truth. Drop references to removed docs (ai-tools.md).

---

## Area G — Context docs overhaul

Reduce to three living files; everything volatile stays out of prose.

### G1. CONTEXT.md (rewrite)

Conceptual **glossary only**: module, profile, bootstrap, validated symlink
farm, directory folding, autostart, controller, secrets loading, script
conventions. **Remove the per-module inventory table** — the filesystem
(`config/*/*`) + `profiles/*.json` are the single source of truth.

### G2. AGENTS.md (rewrite, repo-specific)

Replace the generic superpowers boilerplate with guidance for _this_ repo:

- Repo layout and where things live.
- How to add / move / retire a module.
- Conventional-commit style and the backdating norm (optional).
- Secrets workflow pointer.
- Bootstrap command summary.
- **Standing rule:** update CONTEXT.md / AGENTS.md / CLAUDE.md (and README.md
  if user-facing) on any significant change.
- Note: if AGENTS.md grows too large, split detailed topics into `docs/agents/`
  (escape hatch, not used now).

### G3. CLAUDE.md (create)

Thin pointer that imports AGENTS.md (`@AGENTS.md`) so there is one source of
truth for both Claude Code and other agents (obra/superpowers convention).

### G4. Removals

Delete `docs/adr/` (0001-0003), `docs/agents/` (domain/issue-tracker/
triage-labels), `docs/keybindings.md`, `docs/ai-tools.md`, `docs/yazi.md`.
Keep `docs/secrets.md` (updated) and `docs/script-style.md`.

### G5. README.md (update)

- New `script/` paths (+ root shim note).
- Drop links to removed docs; drop the "AI tooling" section's dead pointer.
- Fix stack/architecture drift (lazygit→`app/git`, editor reality, theming).
- Keep it an entry point; no module/package tables.

---

## Area H — Granular commits (chronological, backdated)

Commit the whole tree as conventional commits ordered by each module's latest
file mtime; set `GIT_AUTHOR_DATE`/`GIT_COMMITTER_DATE` to that mtime. Moves stay
atomic (deletion + addition together) so git records renames.

**Renames:** aria2+yt-dlp→`app/download-tools`; lazygit+gitconfig+
gitignore_global→`app/git`; `desktop/wal`→`app/pywal`.
**Deletions:** `app/imv`, `nvim-pack-lock.json`, opencode `package.json`.
**New:** alacritty, dev-tools, system-tools, obs-studio (config only), ai-tools,
mpd additions (cava/lyricspot), `secrets/`.

**Order** (by mtime; backdated). Today's new work (nvim, yazi, ai-tools, secrets
relocation, bootstrap relocate/improve, docs overhaul, install-package) lands in
the 2026-06-17 group, sequenced logically:

1. `refactor(pywal): move wal module to app/pywal` (2025-12-30)
2. `refactor(download-tools): consolidate aria2 + yt-dlp` (2026-03-21)
3. `feat(mpd): add cava + lyricspot` (2026-06-12)
4. `feat(alacritty): add terminal config` (2026-06-14)
5. `feat(dev-tools): add atuin/fd/herdr/mise/ripgrep` (2026-06-14)
6. `refactor(scripts): update noctalia-autostart` (2026-06-14)
7. `refactor(git): consolidate lazygit + gitconfig into app/git` (2026-06-14)
8. `feat(system-tools): add btop + htop` (2026-06-15)
9. `refactor(mango): update binds/tags/scripts` (2026-06-16)
10. `refactor(archlinux): update shell/XDG/flags` (2026-06-16)
11. `refactor(kitty): update config + theme` (2026-06-16)
12. `feat(obs-studio): add OBS config (excl. logs/profiler)` (2026-06-16)
13. `refactor(fish): update config/aliases/nvim integration` (2026-06-16)
14. `refactor(espanso): restructure matches` (2026-06-16)
15. `fix(nvim): selene vim std, enable lua_ls, lint crash, project-root cd` (2026-06-17)
16. `refactor(yazi): full minimalist config` (2026-06-17)
17. `feat(ai-tools): back up claude/rtk/tirith config` (2026-06-17)
18. `refactor(secrets): relocate to root secrets/, decouple from fish` (2026-06-17)
19. `feat(bootstrap): folding, restow, adopt, undo-profile, dry-run/force; move to script/` (2026-06-17)
20. `docs: overhaul context files (CONTEXT/AGENTS/CLAUDE), rewrite install-package, prune stale docs` (2026-06-17)
21. `chore: sync profiles + retire imv` (2026-06-17)

Exact grouping finalized against live `git status`. Final step: `git push origin main`.

---

## Verification Strategy

- **nvim:** lua file shows no selene `vim` warnings; lua_ls attaches; `<leader>cd`
  cds to project root; missing-linter path doesn't crash.
- **yazi:** clean launch, no dead-keymap errors.
- **ai-tools:** only config staged.
- **secrets:** `sops -d` works at new path; bash + fish both load vars.
- **bootstrap:** `--dry-run` + round-trip + `undo profile`; root shim works.
- **docs:** removed files gone; README links valid; CONTEXT/AGENTS/CLAUDE
  consistent.
- **repo:** `git status` clean; `git log --date=short` chronological; push OK.

## Risks

- **Backdated commits** set dates on new commits only (no history rewrite) — safe.
- **Auto-folding** could fold a dir that should be file-level → mitigated by
  conservative "target must not exist" rule + `--dry-run` review.
- **adopt** moves real files → gated behind explicit command + `--dry-run`.
- **Secrets relocation** touches login shell wiring → verify both bash and fish
  before committing; keep a backup of the old store until verified.
- **Large scope in one session** → commit per area as it completes so progress
  is durable even if the session is interrupted.
