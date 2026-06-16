# Dotfiles Cleanup & Refactor — Design

**Date:** 2026-06-17
**Goal:** Land all in-flight work, finish half-done refactors, and end with a clean working tree pushed to `origin/main`.

## Context

The working tree carries a large module reorganization plus several incomplete
refactors. This spec finishes that work, organizes it into granular
chronological commits, and resolves four design decisions confirmed with the
user.

Scope is five independent areas plus a suggestions deliverable. Each area is
self-contained; the only shared touchpoints are `profiles/laptop.json` and
`CONTEXT.md` (the module registry).

## Confirmed Decisions

| Area             | Decision                                                                               |
| ---------------- | -------------------------------------------------------------------------------------- |
| Bootstrap        | Improve the current script (keep validation/profiles/secrets)                          |
| Yazi             | Full minimalist — remove all traces of dropped plugins                                 |
| Neovim           | Bug-fixes only + the `vim`-global fix + a `cd to project root` keymap. No new plugins. |
| nvim `cd` keymap | cd to **project root** (marker search via `vim.fs.root`)                               |
| Commit dates     | **Backdate** each commit to the module's latest file mtime                             |
| ai-tools         | **Back up** the config; add narrow `.gitignore` for runtime noise                      |
| obs-studio / imv | Commit obs config only (exclude logs/profiler_data); retire imv                        |

---

## Area A — Neovim (bug-fixes + targeted additions)

### A1. Crash fix — undefined `LazyVim` global

`lua/plugins/lint.lua:80` calls `LazyVim.warn(...)`, a leftover from LazyVim.
It throws when a configured linter is not found.

**Fix:** replace with
`vim.notify("Linter not found: " .. name, vim.log.levels.WARN)`.

### A2. `vim` flagged as undefined global (root cause)

The real culprit is **selene**, not lua_ls, and not the symlink.
`lua/plugins/lint.lua:24` runs `selene` for lua files. `selene.toml` defines no
`std`, so selene uses plain Lua's stdlib and flags every `vim.*`. LazyVim used
to ship a `selene.toml` with `std = "vim"` plus a `vim.yml` std file; that was
lost in the migration. `selene.toml` is correctly found via upward search from
the symlinked buffer path, so the symlink/root-detection hypothesis is not the
cause.

**Fix:**

1. Add `config/app/nvim/.config/nvim/vim.yml` (selene std):
   ```yaml
   ---
   base: lua51
   globals:
     vim:
       any: true
   ```
2. Set `std = "vim"` in `selene.toml` (keep existing `[lints]` allows).

`vim: { any: true }` silences the false positives while keeping the rest of
selene's lint value (no blanket `undefined_variable = "allow"`).

### A3. Re-enable lua_ls

`lua-language-server` is installed and `lazydev` is already configured
(`lsp.lua:8-18`) to feed it the `vim` library, but `lua_ls` is commented out
(`lsp.lua:63-65`) — so there is currently zero lua semantic help in-editor.

**Fix:** uncomment the `lua_ls = { _cmd = "lua-language-server" }` entry. This is
not a new plugin; the binary and lazydev wiring already exist.

### A4. New keymap — cd to project root

Add a normal-mode keymap (`<leader>cd`) that changes the working directory to
the project root of the current file, found by walking up for markers via
`vim.fs.root(0, { ".git", ".hg", ".svn", "Makefile", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", ".luarc.json" })`,
falling back to the file's directory when no marker is found. Notify the user of
the new cwd.

### A5. Documentation

Add a short note (in the nvim config, e.g. a comment near the selene setup or a
brief `README`) recording the selene `std` / lua_ls finding so it does not
recur.

**Out of scope (per decision):** comment-toggle, notify.nvim, mini.diff,
session management, todo-comments, inlay-hints auto-enable, format-on-save
expansion.

---

## Area B — Yazi (full minimalist)

The `package.toml` plugin list is already empty, but dead references remain.

**Changes:**

1. `keymap.toml` — remove commented/orphaned binds referencing removed plugins:
   `Z` (fzf), `z` (zoxide) at lines 15-16; `g D` (ripdrag), `g m` (mount),
   `g P` (clipboard), `g M` (mediainfo), `c m` (chmod) and the surrounding
   "Core workflow helpers" / "Optional power-user actions" sections (lines
   38-50).
2. `init.lua` — delete commented-out setup blocks for `save-clipboard-to-file`,
   `spot`, `starship` (lines 1-38). Keep the symlink + user/group statusbar
   additions.
3. `yazi.toml` — delete the commented `[plugin]` previewers/preloaders/spotters
   block (lines 38-59) and its explanatory comment.
4. `docs/yazi.md` — rewrite to describe the **actual** lean config (no phantom
   plugin catalog). State the minimalist philosophy and what was intentionally
   dropped.

**Verify:** `yazi --version` loads config without errors (or a config check if
available).

---

## Area C — ai-tools (back up config + ignore noise)

The repo currently holds only config files under `.claude/`, `.config/rtk/`,
`.config/tirith/`, `.tirith/` — no secrets (verified). The user wants these
backed up.

**Changes:**

1. Commit the untracked config files:
   `.claude/{CLAUDE.md,RTK.md,settings.json,statusline-command.sh}`,
   `.config/rtk/config.toml`, `.config/tirith/gateway.yaml`, `.tirith/policy.yaml`.
2. Stage the existing deletion of `.config/opencode/package.json`.
3. Add a narrow `.gitignore` inside the ai-tools module to keep runtime noise
   out of future commits while preserving the config, e.g.:
   ```gitignore
   # ai-tools: track config, ignore runtime state
   .claude/projects/
   .claude/todos/
   .claude/shell-snapshots/
   .claude/statsig/
   .claude/*.json.backup
   .claude/history.jsonl
   .config/rtk/*.db
   .config/rtk/*.log
   .config/rtk/history/
   .config/tirith/*.log
   .tirith/*.log
   ```
   (Exact ignore globs validated against what each tool writes at runtime
   during implementation.)
4. Light optimization (only if quick): remove the empty `.codex/hooks.json`;
   note the `RTK.md` duplication between `.claude/` and `.codex/`.

**Verify:** `git status` shows only intended files staged; no `*.db`, `*.log`,
or session dirs tracked.

---

## Area D — Bootstrap (make it feel like stow, keep the power)

`bootstrap.sh` already does file-by-file symlinking with profiles, manifests,
validation, conflict resolution, secrets check, and a `directory_links` escape
hatch. The discomfort vs stow is ergonomic. Improve in place.

**Changes:**

1. **Auto directory-folding heuristic** — when a module subtree maps cleanly to
   a single target directory that does not yet exist, link the directory instead
   of every file (reduces symlink/manifest sprawl). The explicit
   `directory_links` escape hatch remains for forced folding.
2. **`restow <category/module>`** — idempotent re-link (undo + use in one).
3. **`adopt <category/module>`** — move existing `$HOME` files into the repo,
   then link.
4. **`undo profile <name>`** — roll back every module in a profile (the
   bidirectional counterpart to `profile`).
5. **`--dry-run`** — print planned actions without touching the filesystem.
6. **`--force`** — non-interactive conflict resolution (auto-overwrite).
7. **Simpler CLI** — `setup.sh` infers the command from the argument
   (`setup app/fish` ≡ `setup use app/fish`).
8. Update `CONTEXT.md` (Bootstrap section) and `README.md` for the new commands
   and flags.

**Verify:** `bootstrap.sh --dry-run profile lab` and a `use`/`restow`/`undo`
round-trip on a throwaway module produce correct, non-destructive output.

---

## Area E — Granular commits (chronological, backdated)

Commit the entire working tree as logical, conventional commits ordered by each
module's latest file mtime, with `GIT_AUTHOR_DATE`/`GIT_COMMITTER_DATE` set to
that mtime so `git log` reflects true chronology. Moves stay atomic
(deletion + addition in the same commit) so git records renames.

**Module reorganization (renames):**

- `app/aria2` + `app/yt-dlp` → `app/download-tools` (content-identical)
- `app/lazygit` + `system/archlinux/.gitconfig` + `.gitignore_global` →
  `app/git` (lazygit identical; gitconfig is a move + whitespace reformat)
- `desktop/wal` → `app/pywal` (content-identical)

**Genuine deletions:** `app/imv`, `nvim-pack-lock.json`, opencode `package.json`.

**New modules:** `alacritty`, `dev-tools`, `system-tools`, `obs-studio`,
`ai-tools`, plus `mpd` additions (cava, lyricspot).

**obs-studio noise:** add `.gitignore` (or omit from staging) for `logs/`,
`profiler_data/`; `system-tools` excludes `htop_history`.

**Proposed commit order** (by mtime; each backdated):

1. `refactor(pywal): move wal module to app/pywal` (2025-12-30)
2. `refactor(download-tools): consolidate aria2 + yt-dlp` (2026-03-21)
3. `feat(mpd): add cava + lyricspot configs` (2026-06-12)
4. `feat(alacritty): add terminal config` (2026-06-14)
5. `feat(dev-tools): add atuin/fd/herdr/mise/ripgrep` (2026-06-14)
6. `refactor(scripts): update noctalia-autostart` (2026-06-14)
7. `feat(bootstrap): folding, restow, adopt, undo-profile, dry-run/force` (2026-06-14)
8. `refactor(git): consolidate lazygit + gitconfig into app/git` (2026-06-14)
9. `docs: update install-package notes` (2026-06-14)
10. `feat(system-tools): add btop + htop` (2026-06-15)
11. `refactor(mango): update binds/tags/scripts` (2026-06-16)
12. `refactor(archlinux): update shell/XDG/flags` (2026-06-16)
13. `refactor(kitty): update config + theme` (2026-06-16)
14. `feat(obs-studio): add OBS config` (2026-06-16)
15. `refactor(fish): update config/aliases/nvim integration` (2026-06-16)
16. `refactor(espanso): restructure matches` (2026-06-16)
17. `fix(nvim): selene vim std, lua_ls, lint crash, project-root cd` (2026-06-17)
18. `refactor(yazi): full minimalist config` (2026-06-17)
19. `feat(ai-tools): back up claude/rtk/tirith config` (2026-06-17)
20. `chore: sync module registry (profiles + CONTEXT) and retire imv` (2026-06-17)
21. `docs: add tooling suggestions` (2026-06-17)

Exact grouping/order finalized against `git status` at implementation time.
Final step: `git push origin main`.

---

## Area F — Suggestions (deliverable, not implemented today)

Write `docs/suggestions.md` (or similar) listing worthwhile tools/config ideas
discovered during this pass — e.g. selectively reintroducing a few high-value
nvim niceties later, yazi plugins worth revisiting, ai-tools README, bootstrap
`status`/`list` command. Presented as a menu, not applied.

---

## Verification Strategy

- **nvim:** open a lua file, confirm no `vim` selene warnings, lua_ls attaches,
  `<leader>cd` changes cwd to project root; trigger a missing-linter path to
  confirm no crash.
- **yazi:** launch, confirm clean config load, no dead-keymap errors.
- **ai-tools:** `git status` shows only config staged.
- **bootstrap:** `--dry-run` + round-trip on a throwaway module; `undo profile`.
- **repo:** `git status` clean after commits; `git log --date=short` shows
  chronological order; `git push` succeeds.

## Risks

- **Backdated commits** rewrite author/committer dates only (no history rewrite
  of existing commits) — safe on new commits.
- **Auto-folding heuristic** could fold a directory that should stay file-level;
  mitigated by `--dry-run` review and conservative "target dir must not exist"
  condition.
- **adopt** moves real files; gated behind explicit command + `--dry-run`.
