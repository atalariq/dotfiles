# Housekeeping (design)

**Date:** 2026-06-26
**Status:** Approved (brainstorm), pending implementation plan
**Scope:** Sub-project E of the dotfiles audit. Independent cleanup chores;
no architectural change.

---

## Goal

Remove a retired module, correct stale docs, and clear finished TODO items so the
repo reflects reality.

## Items

### E1 — Retire the `zed` module

zed is no longer used. Retire per AGENTS.md "How to Retire a Module":

- `./setup.sh undo app/zed` — remove the `~/.config/zed` symlink.
- `git rm -r config/app/zed/` — removes `keymap.json`, `settings.json`,
  `settings_backup.json` (backup removed with the module, per decision), and
  `themes/noctalia.json`.
- Remove `"app/zed"` from `profiles/laptop.json`.
- Drop `"zed"` from `community_ids` in `~/.local/state/noctalia/settings.toml`
  `[theme.templates]` (Noctalia was templating zed; with the app gone it should
  stop — same disjointness rule as A2bc). Runtime-state edit, not stow-tracked.

### E2 — Fix stale README tech-stack rows

In `README.md` (the `## Tech stack` table):

- `Editor | Zed | Neovim` → `Editor | Neovim | —` (zed retired).
- `Multiplexer | zellij | —` → `Multiplexer | herdr | —` (current multiplexer;
  sub-project B will later revise to tmux-primary).
  Also remove any lingering `zed` reference in `CONTEXT.md` if present (Standing
  Rule on module retirement).

### E3 — espanso restart

Run `espanso restart` so the `:ai` picker picks up the moved snippets path
(`config/app/espanso/.config/espanso/snippets/`). Runtime action; no repo change.

### E4 — Delete TODO.md

Every item in `TODO.md` is now complete: the espanso snippet move (committed), the
working-tree hygiene triage, the snippets/skills concept-drift follow-up, and the
entire AI-tools approval section (delivered by sub-project D). `git rm TODO.md`.

### E5 — `.archived/` left as-is

`.archived/` holds the kitty-blog draft (a personal writing artifact) and old
PLAN/TODO. Not dotfiles config — do not touch.

---

## Sequencing & verification

1. E1 (zed): `setup.sh undo`, `git rm`, profile edit, noctalia settings edit.
   Verify `~/.config/zed` symlink gone; `./setup.sh --dry-run profile laptop`
   succeeds without `app/zed`.
2. E2 (README/CONTEXT): edit rows; markdown still renders; no `zed`/`zellij`
   left in the tech-stack table.
3. E4 (TODO.md): `git rm`; confirm gone.
4. E3 (espanso): `espanso restart` (or note for the user if espanso isn't
   running); confirm exit 0.
5. Commit each as its own logical change (conventional commits:
   `chore(zed): retire module`, `docs(readme): fix stale tech-stack rows`,
   `chore: remove completed TODO.md`).

## Out of scope

- Sub-project B (tmux/herdr) — the README Multiplexer row is set to the current
  `herdr` and will be revised there.
- `.archived/` contents.
- Any other module or config.
