# Housekeeping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retire the unused `zed` module, correct two stale README rows, and delete the now-fully-completed `TODO.md` — plus an `espanso restart` so the `:ai` picker picks up the moved snippets.

**Architecture:** Pure repo cleanup — no code. Module retirement via the documented `setup.sh undo` + `git rm` + profile edit; doc fixes; file deletion; one runtime command.

**Tech Stack:** GNU stow (`setup.sh`), git, markdown.

**Scope:** Sub-project E. Spec: `docs/superpowers/specs/2026-06-26-housekeeping-design.md`. `.archived/` is left untouched. The README Multiplexer row is set to the current `herdr` (sub-project B will later make it tmux-primary).

**Branch:** `cd ~/Repos/dotfiles && git checkout -b feat/housekeeping`.

**Repo path:** `DOTFILES` = `~/Repos/dotfiles`.

---

## File Structure

- Delete: `config/app/zed/` (whole module), `TODO.md`.
- Modify: `profiles/laptop.json` (drop `app/zed`), `README.md` (two tech-stack rows).
- Runtime only (no repo change): `~/.local/state/noctalia/settings.toml` (verify zed absent), `espanso restart`.

---

## Task 1: Retire the zed module

**Files:**

- Modify: `profiles/laptop.json`
- Delete: `config/app/zed/` (keymap.json, settings.json, settings_backup.json, themes/noctalia.json)

- [ ] **Step 1: Remove the deployed symlink.**

Run:

```bash
cd ~/Repos/dotfiles
./setup.sh undo app/zed
ls -ld ~/.config/zed 2>&1 || echo "symlink gone"
```

Expected: undo reports removing the `~/.config/zed` link; the `ls` then reports the path no longer exists (`symlink gone`).

- [ ] **Step 2: Remove the module from the repo.**

Run:

```bash
cd ~/Repos/dotfiles
git rm -r config/app/zed/
```

Expected: git stages deletion of all 4 files under `config/app/zed/`.

- [ ] **Step 3: Drop `app/zed` from the laptop profile.**

Edit `profiles/laptop.json` — remove the `"app/zed",` line. The `modules` array around it currently reads:

```json
    "app/yazi",
    "app/zed",
    "desktop/mango",
```

Change it to:

```json
    "app/yazi",
    "desktop/mango",
```

- [ ] **Step 4: Verify the profile is valid JSON and zed-free, and dry-run deploys clean.**

Run:

```bash
cd ~/Repos/dotfiles
python3 -c "import json; m=json.load(open('profiles/laptop.json'))['modules']; assert 'app/zed' not in m; print('profile OK, modules:', len(m))"
./setup.sh --dry-run profile laptop 2>&1 | grep -iE 'zed|error' || echo "no zed / no errors in dry-run"
```

Expected: `profile OK, modules: 20` (was 21); and `no zed / no errors in dry-run`.

- [ ] **Step 5: Confirm Noctalia no longer templates zed (verify-only — already pruned).**

Run:

```bash
grep "community_ids" ~/.local/state/noctalia/settings.toml
```

Expected: the list does NOT contain `"zed"` (currently `[ "papirus-icons", "yazi", "zathura" ]`). If `"zed"` IS present, edit the file to remove it; otherwise no change needed.

- [ ] **Step 6: Commit.**

```bash
cd ~/Repos/dotfiles
git add profiles/laptop.json
git commit -m "chore(zed): retire module (no longer used)"
```

(The `git rm -r config/app/zed/` from Step 2 is already staged; this commit includes both the deletions and the profile edit.)

---

## Task 2: Fix stale README tech-stack rows

**Files:**

- Modify: `README.md` (the `## Tech stack` table, rows for Editor and Multiplexer)

- [ ] **Step 1: Update the two rows.** In `README.md`, change:

```
| Multiplexer         | zellij                                | —              |
| Editor              | Zed                                   | Neovim         |
```

to:

```
| Multiplexer         | herdr                                 | —              |
| Editor              | Neovim                                | —              |
```

(A markdown formatter may realign the column widths on save — that's fine.)

- [ ] **Step 2: Verify no stale references remain in the tech-stack table.**

Run:

```bash
cd ~/Repos/dotfiles
grep -nE "zellij|Zed" README.md || echo "no zellij/Zed left"
grep -nE "Multiplexer|Editor" README.md
```

Expected: `no zellij/Zed left`; the Multiplexer row shows `herdr` and the Editor row shows `Neovim`.

- [ ] **Step 3: Commit.**

```bash
cd ~/Repos/dotfiles
git add README.md
git commit -m "docs(readme): fix stale tech-stack rows (zed retired, herdr mux)"
```

---

## Task 3: Delete TODO.md + espanso restart

**Files:**

- Delete: `TODO.md`

- [ ] **Step 1: Confirm TODO.md has no open items, then delete it.**

All TODO.md items are complete (espanso snippet move committed; hygiene triage done; snippets/skills follow-up done; the AI-tools approval section delivered by sub-project D). Run:

```bash
cd ~/Repos/dotfiles
git rm TODO.md
```

Expected: TODO.md staged for deletion.

- [ ] **Step 2: Commit the deletion.**

```bash
cd ~/Repos/dotfiles
git commit -m "chore: remove completed TODO.md"
```

- [ ] **Step 3: espanso restart (runtime — the last open TODO item).**

Run:

```bash
espanso restart 2>&1 || echo "espanso not running/installed — restart manually before next use"
```

Expected: espanso restarts (or the fallback note prints if it isn't running). This makes the `:ai` picker pick up the moved snippets path. No repo change; nothing to commit.

---

## Self-Review

**Spec coverage:**

- E1 retire zed (undo, git rm, profile, noctalia verify) — Task 1. ✅
- E2 README rows (Editor→Neovim, Multiplexer→herdr); CONTEXT.md has no zed/zellij refs so no CONTEXT change needed — Task 2. ✅
- E3 espanso restart — Task 3 Step 3. ✅
- E4 delete TODO.md — Task 3 Steps 1-2. ✅
- E5 `.archived/` untouched — no task touches it. ✅

**Placeholder scan:** No TBD/TODO; every step has concrete commands/edits + expected output. ✅

**Type/name consistency:** Module path `config/app/zed/` and profile entry `app/zed` consistent across Task 1; module count 21→20 stated in Task 1 Step 4 matches removing one entry; README row target values (`herdr`, `Neovim`) consistent between Task 2 Steps 1 and 2. ✅
