# Dotfiles Cleanup, Refactor & Docs Overhaul — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish all in-flight refactors, relocate secrets, overhaul context docs, and land the entire working tree as granular chronological commits pushed to `origin/main`.

**Architecture:** The repo is a per-module symlink farm under `config/<category>/<module>`, deployed by `bootstrap.sh`/`setup.sh`. Work proceeds in two passes: (1) commit already-finished module changes/moves with backdated timestamps reflecting real mtimes; (2) perform today's new edits (nvim, yazi, ai-tools, secrets, bootstrap, docs) and commit each with natural timestamps. Moves are staged as deletion+addition together so git records renames.

**Tech Stack:** bash, python3 (profile/JSON parsing), git, SOPS+age (secrets), Neovim (Lua, vim.pack), yazi (TOML/Lua), selene, pacman.

**Reference spec:** `docs/superpowers/specs/2026-06-17-dotfiles-cleanup-design.md`

---

## Conventions used in this plan

**Backdated commit helper.** Pre-today commits set both date env vars. Run from repo root, gpg signing disabled to avoid prompts:

```bash
gc() {  # gc "<ISO-date>" "<message>"
  GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" \
    git -c commit.gpgsign=false commit -q -m "$2"
}
```

All commit messages end with the trailer:

```
Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

(omitted from each step below for brevity — always append it).

**Verify-after-change.** This is config/infra, not unit-testable code. Each task ends with a concrete verification (parse/launch/dry-run) instead of a unit test, then a commit.

---

## PASS 1 — Backdated commits for finished module work

> Each task: stage exactly the listed paths, verify staging, commit backdated. Do NOT use `git add -A` globally — stage explicit paths so concerns stay separated.

### Task 1: pywal module move (`desktop/wal` → `app/pywal`)

**Files:**

- Delete: `config/desktop/wal/` (tracked)
- Create: `config/app/pywal/` (untracked, content-identical)

- [ ] **Step 1: Stage the move**

```bash
cd /home/atalariq/Repos/dotfiles
git add config/desktop/wal config/app/pywal
```

- [ ] **Step 2: Verify git detected a rename**

```bash
git diff --cached --find-renames --summary | head
git status --short | grep -E 'wal|pywal' | head
```

Expected: `rename config/desktop/wal/... -> config/app/pywal/...` lines (renames, not separate add/delete).

- [ ] **Step 3: Commit (backdated)**

```bash
gc "2025-12-30T21:12:19+07:00" "refactor(pywal): move wal module to app/pywal"
```

---

### Task 2: download-tools module (aria2 + yt-dlp consolidated)

**Files:**

- Delete: `config/app/aria2/`, `config/app/yt-dlp/`
- Create: `config/app/download-tools/.config/{aria2,yt-dlp}/...`

- [ ] **Step 1: Stage**

```bash
git add config/app/aria2 config/app/yt-dlp config/app/download-tools
```

- [ ] **Step 2: Verify renames**

```bash
git diff --cached --find-renames --summary | grep -E 'aria2|yt-dlp|download-tools'
```

Expected: rename lines for both `aria2.conf` and yt-dlp `config`.

- [ ] **Step 3: Commit**

```bash
gc "2026-03-21T11:14:11+07:00" "refactor(download-tools): consolidate aria2 + yt-dlp"
```

---

### Task 3: mpd additions (cava + lyricspot)

**Files:**

- Create: `config/app/mpd/.config/cava/`, `config/app/mpd/.config/lyricspot/`

- [ ] **Step 1: Stage**

```bash
git add config/app/mpd/.config/cava config/app/mpd/.config/lyricspot
```

- [ ] **Step 2: Verify**

```bash
git status --short config/app/mpd | head
```

Expected: only new `cava/` and `lyricspot/` files staged (`A`).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-12T08:37:47+07:00" "feat(mpd): add cava + lyricspot configs"
```

---

### Task 4: alacritty module (new)

- [ ] **Step 1: Stage**

```bash
git add config/app/alacritty
```

- [ ] **Step 2: Verify**

```bash
git status --short config/app/alacritty
```

Expected: `A config/app/alacritty/.config/alacritty/alacritty.toml` (+ themes).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-14T08:45:35+07:00" "feat(alacritty): add terminal config"
```

---

### Task 5: dev-tools module (new)

- [ ] **Step 1: Stage**

```bash
git add config/app/dev-tools
```

- [ ] **Step 2: Verify**

```bash
git status --short config/app/dev-tools
```

Expected: atuin, fd, herdr, mise, ripgrep config files staged.

- [ ] **Step 3: Commit**

```bash
gc "2026-06-14T10:39:34+07:00" "feat(dev-tools): add atuin/fd/herdr/mise/ripgrep configs"
```

---

### Task 6: scripts (noctalia-autostart update)

**Files:**

- Modify: `config/misc/scripts/.local/script/noctalia-autostart`

- [ ] **Step 1: Stage**

```bash
git add config/misc/scripts/.local/script/noctalia-autostart
```

- [ ] **Step 2: Verify it is a script with valid syntax**

```bash
bash -n config/misc/scripts/.local/script/noctalia-autostart && echo OK
```

Expected: `OK`.

- [ ] **Step 3: Commit**

```bash
gc "2026-06-14T16:33:07+07:00" "refactor(scripts): update noctalia-autostart"
```

---

### Task 7: git module (lazygit + gitconfig consolidated into `app/git`)

**Files:**

- Delete: `config/app/lazygit/`, `config/system/archlinux/.gitconfig`, `config/system/archlinux/.gitignore_global`
- Create: `config/app/git/` (lazygit configs + `.gitconfig` + `.gitignore_global`)

- [ ] **Step 1: Stage exactly these paths (not other archlinux files)**

```bash
git add config/app/lazygit config/app/git \
  config/system/archlinux/.gitconfig config/system/archlinux/.gitignore_global
```

- [ ] **Step 2: Verify renames + that no unrelated archlinux files were staged**

```bash
git diff --cached --find-renames --summary | grep -E 'lazygit|app/git|gitconfig|gitignore_global'
git diff --cached --name-only | grep archlinux
```

Expected: rename lines; the only archlinux paths staged are `.gitconfig` and `.gitignore_global` (deletions).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-14T17:21:06+07:00" "refactor(git): consolidate lazygit + gitconfig into app/git"
```

---

### Task 8: system-tools module (btop + htop)

**Files:**

- Create: `config/app/system-tools/.config/{btop,htop}/...`
- Exclude: `config/app/system-tools/.config/htop/htop_history` (runtime state)

- [ ] **Step 1: Stage everything except htop_history**

```bash
git add config/app/system-tools
git reset -q config/app/system-tools/.config/htop/htop_history
```

- [ ] **Step 2: Verify htop_history is NOT staged**

```bash
git diff --cached --name-only | grep htop_history && echo "STILL STAGED (bad)" || echo "excluded OK"
```

Expected: `excluded OK`.

- [ ] **Step 3: Add module `.gitignore` so it stays out**

Create `config/app/system-tools/.config/htop/.gitignore`:

```gitignore
# htop runtime state
htop_history
```

```bash
git add config/app/system-tools/.config/htop/.gitignore
```

- [ ] **Step 4: Commit**

```bash
gc "2026-06-15T16:21:40+07:00" "feat(system-tools): add btop + htop configs"
```

---

### Task 9: mango (binds/tags/scripts update)

**Files:**

- Modify: `config/desktop/mango/...` (modified files only)

- [ ] **Step 1: Stage all mango changes**

```bash
git add config/desktop/mango
```

- [ ] **Step 2: Verify scripts still parse**

```bash
for s in config/desktop/mango/.config/mango/script/*; do bash -n "$s" 2>/dev/null && echo "ok $s" || echo "SKIP/non-bash $s"; done
```

Expected: scripts report `ok` (non-bash ones may skip — acceptable).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-16T09:51:44+07:00" "refactor(mango): update binds, tags, and scripts"
```

---

### Task 10: archlinux (shell / XDG / flags — excluding the moved git files)

**Files:**

- Modify: `.bash_profile`, `.bashrc`, `.profile`, `.zshrc`, `.config/brave-flags.conf`, `.config/chrome-flags.conf`, `.config/mimeapps.list`

> NOTE: `.profile` will be edited again in Task 16 (secrets). Here commit only its CURRENT state. The git-file deletions were already committed in Task 7.

- [ ] **Step 1: Stage remaining archlinux changes**

```bash
git add config/system/archlinux
```

- [ ] **Step 2: Verify the gitconfig deletions are already committed (not re-appearing)**

```bash
git status --short config/system/archlinux
```

Expected: only modified shell/XDG/flag files; `.gitconfig`/`.gitignore_global` NOT listed (already committed in Task 7).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-16T12:00:47+07:00" "refactor(archlinux): update shell, XDG, and browser flags"
```

---

### Task 11: kitty (config + theme)

- [ ] **Step 1: Stage**

```bash
git add config/app/kitty
```

- [ ] **Step 2: Verify kitty config parses (if kitty present)**

```bash
command -v kitty >/dev/null && kitty --config config/app/kitty/.config/kitty/kitty.conf -o term=xterm-kitty --debug-config >/dev/null 2>&1 && echo "config ok" || echo "kitty not present / skip"
```

Expected: `config ok` or skip message.

- [ ] **Step 3: Commit**

```bash
gc "2026-06-16T20:38:13+07:00" "refactor(kitty): update config and theme"
```

---

### Task 12: obs-studio (config only — exclude logs/profiler_data)

**Files:**

- Create: `config/app/obs-studio/.config/obs-studio/...` (profiles, scenes, themes, ini, plugin_config, plugin_manager)
- Exclude: `logs/`, `profiler_data/`

- [ ] **Step 1: Add a module `.gitignore` for noise**

Create `config/app/obs-studio/.config/obs-studio/.gitignore`:

```gitignore
# OBS runtime noise
logs/
profiler_data/
crashes/
```

- [ ] **Step 2: Stage everything, then unstage the noise**

```bash
git add config/app/obs-studio
git reset -q "config/app/obs-studio/.config/obs-studio/logs" \
             "config/app/obs-studio/.config/obs-studio/profiler_data"
```

- [ ] **Step 3: Verify no logs/profiler staged**

```bash
git diff --cached --name-only | grep -E 'obs-studio/.config/obs-studio/(logs|profiler_data)/' && echo "STILL STAGED (bad)" || echo "excluded OK"
git diff --cached --name-only | grep 'obs-studio/.config/obs-studio/.gitignore' && echo "gitignore staged OK"
```

Expected: `excluded OK` and `gitignore staged OK`.

- [ ] **Step 4: Commit**

```bash
gc "2026-06-16T22:13:32+07:00" "feat(obs-studio): add OBS config (excl. logs/profiler)"
```

---

### Task 13: fish (config/aliases/nvim integration — EXCLUDING secrets files)

**Files:**

- Modify: `config.fish`, `conf.d/00-dev.fish`, `conf.d/10-aliases.fish`, `conf.d/40-nvim.fish`, `.config/starship.toml`
- DO NOT stage here: `conf.d/90-secrets.fish`, `conf.d/secrets.sh`, `secrets.yaml` (handled in Task 16)

- [ ] **Step 1: Stage only the non-secrets fish files**

```bash
git add \
  config/app/fish/.config/fish/config.fish \
  config/app/fish/.config/fish/conf.d/00-dev.fish \
  config/app/fish/.config/fish/conf.d/10-aliases.fish \
  config/app/fish/.config/fish/conf.d/40-nvim.fish \
  config/app/fish/.config/starship.toml
```

- [ ] **Step 2: Verify fish syntax + that no secrets files are staged**

```bash
for f in config/app/fish/.config/fish/config.fish config/app/fish/.config/fish/conf.d/00-dev.fish config/app/fish/.config/fish/conf.d/10-aliases.fish config/app/fish/.config/fish/conf.d/40-nvim.fish; do fish -n "$f" && echo "ok $f"; done
git diff --cached --name-only | grep -E 'secrets' && echo "SECRETS STAGED (bad)" || echo "no secrets staged OK"
```

Expected: each `ok`, and `no secrets staged OK`.

- [ ] **Step 3: Commit**

```bash
gc "2026-06-16T22:33:32+07:00" "refactor(fish): update config, aliases, nvim integration"
```

---

### Task 14: espanso (restructure matches)

**Files:**

- Modify: `config/default.yml`, `match/base.yml`
- Delete: `config/kitty.yml`, `match/{arrow,form,personal}.yml`
- Create: `match/personal.yaml`, `match/snippet.yaml`

- [ ] **Step 1: Stage all espanso changes**

```bash
git add config/app/espanso
```

- [ ] **Step 2: Verify YAML parses**

```bash
for f in $(git diff --cached --name-only config/app/espanso | grep -E '\.ya?ml$'); do python3 -c "import yaml,sys; yaml.safe_load(open('$f'))" && echo "ok $f"; done
```

Expected: each existing file `ok` (deleted files won't be checked).

- [ ] **Step 3: Commit**

```bash
gc "2026-06-16T23:46:27+07:00" "refactor(espanso): restructure match files"
```

---

## PASS 2 — Today's new edits (natural timestamps)

> From here, commit normally (no `gc` backdating):
> `git -c commit.gpgsign=false commit -q -m "..."` (+ Co-Authored-By trailer).

### Task 15: Neovim bug-fixes + project-root cd keymap

**Files:**

- Create: `config/app/nvim/.config/nvim/vim.yml`
- Modify: `config/app/nvim/.config/nvim/selene.toml`
- Modify: `config/app/nvim/.config/nvim/lua/plugins/lint.lua:80`
- Modify: `config/app/nvim/.config/nvim/lua/core/keymaps.lua`

- [ ] **Step 1: Add selene `vim` std file**

Create `config/app/nvim/.config/nvim/vim.yml`:

```yaml
---
base: lua51
globals:
  vim:
    any: true
```

- [ ] **Step 2: Point selene.toml at the vim std**

Edit `config/app/nvim/.config/nvim/selene.toml` to:

```toml
std = "lua51+vim"

[lints]
mixed_table = "allow"
mixed_fields = "allow"
```

(Selene auto-loads `vim.yml` from the config dir for the `+vim` segment.)

- [ ] **Step 3: Fix the LazyVim crash in lint.lua**

In `lua/plugins/lint.lua`, replace line 80:

```lua
      LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
```

with:

```lua
      vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
```

- [ ] **Step 4: Add the project-root cd keymap**

Append to `lua/core/keymaps.lua` (matches existing `map`/`desc` style):

```lua
-- cd to project root of the current file (markers), fallback to file dir
map("n", "<leader>cd", function()
  local markers = { ".git", ".hg", ".svn", "Makefile", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", ".luarc.json" }
  local root = vim.fs.root(0, markers)
  if not root then
    local fname = vim.api.nvim_buf_get_name(0)
    root = fname ~= "" and vim.fs.dirname(fname) or vim.uv.cwd()
  end
  vim.cmd.cd(vim.fn.fnameescape(root))
  vim.notify("cwd → " .. root)
end, { desc = "cd to project root" })
```

- [ ] **Step 5: Verify selene no longer flags `vim`**

```bash
cd /home/atalariq/Repos/dotfiles/config/app/nvim/.config/nvim
selene lua/core/keymaps.lua
```

Expected: no `undefined variable 'vim'` errors (0 warnings, or only unrelated ones).

- [ ] **Step 6: Verify lua + keymap load in headless nvim**

```bash
nvim --headless "+lua dofile('lua/core/keymaps.lua')" +q 2>&1 | head
nvim --headless "+lua require('plugins.lint')" +q 2>&1 | head
```

Expected: no Lua errors printed (empty or clean output). If nvim isn't on PATH, note and skip.

- [ ] **Step 7: Commit**

```bash
cd /home/atalariq/Repos/dotfiles
git add config/app/nvim/.config/nvim/vim.yml \
        config/app/nvim/.config/nvim/selene.toml \
        config/app/nvim/.config/nvim/lua/plugins/lint.lua \
        config/app/nvim/.config/nvim/lua/core/keymaps.lua
git -c commit.gpgsign=false commit -q -m "fix(nvim): selene vim std, lint crash, project-root cd keymap"
```

---

### Task 16: Neovim — commit remaining migration files

> The bulk migration (init.lua, lsp.lua, cmp.lua, mini.lua, treesitter.lua, dap.lua, autocmds.lua, options.lua, colorscheme.lua, new conform/fzf/gitsigns/utils, after/, snippets/, deleted nvim-pack-lock.json) is already in the working tree from the user's WIP. Commit it as the migration record.

**Files:** all remaining modified/untracked/deleted nvim files.

- [ ] **Step 1: Stage all remaining nvim changes**

```bash
git add config/app/nvim
```

- [ ] **Step 2: Verify the whole config loads headless**

```bash
nvim --headless "+lua print('config loaded ok')" +qa 2>&1 | tail -5
```

Expected: `config loaded ok` with no preceding tracebacks. (Skip if nvim absent.)

- [ ] **Step 3: Commit**

```bash
git -c commit.gpgsign=false commit -q -m "refactor(nvim): migrate from Mason to vim.pack package manager

Modular plugin layout (conform/fzf/gitsigns/lint extracted), blink.cmp,
system-binary LSP servers, ftplugin overrides, custom snippets."
```

---

### Task 17: Yazi — full minimalist cleanup

**Files:**

- Modify: `config/app/yazi/.config/yazi/keymap.toml`
- Modify: `config/app/yazi/.config/yazi/init.lua`
- Modify: `config/app/yazi/.config/yazi/yazi.toml`
- Delete: `docs/yazi.md`

- [ ] **Step 1: Remove dead keymaps**

In `keymap.toml`, delete the commented orphan lines:

- Lines 15-16 (`Z` fzf, `z` zoxide)
- Lines 38-43 (the `# Core workflow helpers` block: bypass `L`/`H`, `O`, `<Enter>`, `<S-Enter>`)
- Lines 45-50 (the `# Optional power-user actions` block: `g D`, `g m`, `g P`, `g M`, `c m`)

Keep the working git-root bind at line 36 (`g r`). The `[mgr] prepend_keymap` list should end cleanly with the existing Goto binds.

- [ ] **Step 2: Remove dead setup blocks in init.lua**

In `init.lua`, delete lines 1-38 (the commented `save-clipboard-to-file`, `spot`, `starship` setup blocks). Keep lines 40-63 (symlink status + user/group status). File should now start with the `-- https://yazi-rs.github.io/docs/tips/#symlink-in-status` comment.

- [ ] **Step 3: Remove commented plugin block in yazi.toml**

Open `config/app/yazi/.config/yazi/yazi.toml`; delete the commented `[plugin]` previewers/preloaders/spotters block (around lines 38-59) and its explanatory comment. Leave the rest intact.

- [ ] **Step 4: Delete the stale doc**

```bash
git rm docs/yazi.md
```

- [ ] **Step 5: Verify yazi parses config**

```bash
yazi --version >/dev/null 2>&1 && YAZI_CONFIG_HOME=config/app/yazi/.config/yazi yazi --debug 2>&1 | head -20 || echo "yazi check: launch interactively to confirm"
```

Expected: no TOML/Lua parse errors. (`--debug` prints config diagnostics; if unsupported, confirm by launching yazi once.)

- [ ] **Step 6: Commit**

```bash
git add config/app/yazi docs/yazi.md
git -c commit.gpgsign=false commit -q -m "refactor(yazi): full minimalist config, drop unused plugin scaffolding"
```

---

### Task 18: ai-tools — back up config + ignore runtime noise

**Files:**

- Create: `config/app/ai-tools/.gitignore`
- Stage untracked config + the opencode `package.json` deletion
- Remove empty `.codex/hooks.json` (if empty)

- [ ] **Step 1: Inspect what each tool writes at runtime (to scope ignores)**

```bash
ls -la ~/.claude 2>/dev/null | head -20
ls -la ~/.config/rtk 2>/dev/null | head
ls -la ~/.config/tirith ~/.tirith 2>/dev/null | head
```

Use this to confirm the ignore globs below cover session/cache/db/log files.

- [ ] **Step 2: Create the module `.gitignore`**

Create `config/app/ai-tools/.gitignore`:

```gitignore
# ai-tools: track config, ignore runtime/session state
.claude/projects/
.claude/todos/
.claude/shell-snapshots/
.claude/statsig/
.claude/history.jsonl
.claude/*.log
.config/rtk/*.db
.config/rtk/*.log
.config/rtk/history/
.config/rtk/tee/
.config/tirith/*.log
.tirith/*.log
.tirith/cache/
```

- [ ] **Step 3: Remove the empty codex hooks file (if empty)**

```bash
test -s config/app/ai-tools/.codex/hooks.json || git rm -f config/app/ai-tools/.codex/hooks.json
```

- [ ] **Step 4: Stage config + deletion**

```bash
git add config/app/ai-tools/.gitignore \
        config/app/ai-tools/.claude \
        config/app/ai-tools/.config/rtk \
        config/app/ai-tools/.config/tirith \
        config/app/ai-tools/.tirith
git add config/app/ai-tools/.config/opencode/package.json
```

- [ ] **Step 5: Verify only config staged (no db/log/session dirs)**

```bash
git diff --cached --name-only config/app/ai-tools | grep -E '\.(db|log)$|/(projects|todos|shell-snapshots|statsig|history)/' && echo "NOISE STAGED (bad)" || echo "clean OK"
git diff --cached --name-only config/app/ai-tools
```

Expected: `clean OK`; only the intended config files + `.gitignore` + the `package.json` deletion.

- [ ] **Step 6: Commit**

```bash
git -c commit.gpgsign=false commit -q -m "feat(ai-tools): back up claude/rtk/tirith config, ignore runtime state"
```

---

### Task 19: Secrets relocation to root `secrets/`

**Files:**

- Create: `secrets/load.sh`
- Move: encrypted store → `secrets/secrets.yaml`
- Modify: `config/app/fish/.config/fish/conf.d/90-secrets.fish` (thin wrapper)
- Modify: `config/system/archlinux/.profile` (source shared loader)
- Delete: `config/app/fish/.config/fish/secrets.yaml`, `config/app/fish/.config/fish/conf.d/secrets.sh`
- Modify: `docs/secrets.md`
- (Bootstrap deploy hook added in Task 20)

- [ ] **Step 1: Create `secrets/` and move the encrypted store**

```bash
cd /home/atalariq/Repos/dotfiles
mkdir -p secrets
git mv config/app/fish/.config/fish/secrets.yaml secrets/secrets.yaml
```

- [ ] **Step 2: Create the shell-agnostic POSIX loader**

Create `secrets/load.sh` (deployed to `~/.local/script/secrets-load`):

```sh
#!/usr/bin/env sh
# secrets-load — decrypt SOPS/age secrets and export them.
# Source from ~/.profile (bash/zsh). Fish calls it via a wrapper.
# Requires: sops, age/rage. See docs/secrets.md.

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-${HOME}/.config/age/keys.txt}"

_secrets_file="${SECRETS_FILE:-${HOME}/.config/sops/secrets.yaml}"

[ -f "$_secrets_file" ] || return 0 2>/dev/null || exit 0
command -v sops >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

eval "$(sops -d --output-type dotenv "$_secrets_file" 2>/dev/null \
  | sed -n '/^[A-Za-z_][A-Za-z0-9_]*=/{ s/^/export /; p; }')"

unset _secrets_file
```

```bash
chmod +x secrets/load.sh
```

- [ ] **Step 3: Verify the encrypted store still decrypts at the new path**

```bash
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/age/keys.txt}" sops -d secrets/secrets.yaml >/dev/null && echo "decrypt OK"
```

Expected: `decrypt OK`. (`.sops.yaml` regex `.*secrets\.yaml$` already matches the new path.)

- [ ] **Step 4: Rewrite the fish wrapper to use the shared loader**

Replace `config/app/fish/.config/fish/conf.d/90-secrets.fish` with a thin wrapper that bridges the POSIX loader into fish (keeps the `load_secrets`/`unload_secrets`/`secrets-status` UX, drops the duplicated decrypt logic):

```fish
# ~/.config/fish/conf.d/90-secrets.fish
# Thin wrapper over the shared POSIX loader (~/.local/script/secrets-load).
# Requires: sops, age/rage, bash.

set -g __SECRETS_LOADER "$HOME/.local/script/secrets-load"
set -g __SECRETS_STORE "$HOME/.config/sops/secrets.yaml"

function load_secrets --description "Decrypt and export secrets into fish"
    if not test -f "$__SECRETS_STORE"
        echo "Secrets file not found: $__SECRETS_STORE"
        return 1
    end
    if not command -q sops; or not command -q bash
        echo "sops and bash are required."
        return 1
    end

    set -l tmp (mktemp)
    chmod 600 "$tmp"
    # Run the POSIX loader in bash, then dump the resulting KEY=VALUE pairs NUL-separated.
    bash -c '
        set -euo pipefail
        SECRETS_FILE="'"$__SECRETS_STORE"'"
        . "'"$__SECRETS_LOADER"'"
        sops -d --output-type dotenv "$SECRETS_FILE" 2>/dev/null \
          | grep -E "^[A-Za-z_][A-Za-z0-9_]*=" \
          | sed -E "s/=.*$//" \
          | while read -r k; do printf "%s\0%s\0" "$k" "${!k-}"; done
    ' > "$tmp"

    while read --null key; read --null val
        test -n "$key"; and set -gx "$key" "$val"
    end < "$tmp"
    command rm -f "$tmp"
    set -gx __SECRETS_LOADED 1
    echo "Secrets loaded."
end

function unload_secrets --description "Remove exported secrets from fish"
    test -f "$__SECRETS_STORE"; or return 1
    for key in (sops -d --output-type dotenv "$__SECRETS_STORE" 2>/dev/null | grep -E "^[A-Za-z_][A-Za-z0-9_]*=" | sed -E 's/=.*$//')
        set -e "$key"
    end
    set -e __SECRETS_LOADED
    echo "Secrets unloaded."
end

function secrets-status --description "Show whether secrets are loaded"
    if set -q __SECRETS_LOADED
        echo "Secrets are loaded."
    else
        echo "Secrets are not loaded."
    end
end

if status is-interactive
    if not set -q __SECRETS_LOADED
        load_secrets >/dev/null
    end
end
```

- [ ] **Step 5: Remove the old POSIX loader from the fish module**

```bash
git rm config/app/fish/.config/fish/conf.d/secrets.sh
```

- [ ] **Step 6: Point `.profile` at the shared loader**

In `config/system/archlinux/.profile`, replace any line sourcing the old fish-path loader (`~/.config/fish/conf.d/secrets.sh`) with:

```sh
# Load encrypted secrets (shell-agnostic)
[ -r "$HOME/.local/script/secrets-load" ] && . "$HOME/.local/script/secrets-load"
```

If no such source line exists yet, add the block above near the end of `.profile`.

- [ ] **Step 7: Verify fish wrapper syntax**

```bash
fish -n config/app/fish/.config/fish/conf.d/90-secrets.fish && echo "fish ok"
sh -n secrets/load.sh && echo "sh ok"
```

Expected: `fish ok` and `sh ok`.

- [ ] **Step 8: Update docs/secrets.md**

Rewrite the file locations + flow in `docs/secrets.md`:

- Store: `~/.config/sops/secrets.yaml` (source: `secrets/secrets.yaml`)
- Loader: `~/.local/script/secrets-load` (source: `secrets/load.sh`), sourced by `.profile`
- Fish: `conf.d/90-secrets.fish` thin wrapper
- Update the `sops` create/edit commands to the new path: `sops secrets/secrets.yaml`
- Update the rotation/`updatekeys` paths.

- [ ] **Step 9: Commit (defer bootstrap deploy hook to Task 20)**

```bash
git add secrets config/app/fish/.config/fish/conf.d/90-secrets.fish \
        config/app/fish/.config/fish/conf.d/secrets.sh \
        config/system/archlinux/.profile docs/secrets.md
git -c commit.gpgsign=false commit -q -m "refactor(secrets): relocate to root secrets/, decouple from fish"
```

---

### Task 20: Bootstrap — improvements + relocate to `script/`

**Files:**

- Move: `bootstrap.sh`, `setup.sh` → `script/`
- Create: root `setup.sh` shim
- Modify: `script/bootstrap.sh` (folding, restow, adopt, undo profile, dry-run, force, secrets deploy)
- Modify: `script/setup.sh` (arg inference, path fix)

> Implement and verify incrementally. After each sub-step group, run the dry-run smoke test.

- [ ] **Step 1: Move the scripts and fix DOTFILES_DIR**

```bash
cd /home/atalariq/Repos/dotfiles
mkdir -p script
git mv bootstrap.sh script/bootstrap.sh
git mv setup.sh script/setup.sh
```

In `script/bootstrap.sh`, change the root derivation:

```bash
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

In `script/setup.sh`, change:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP="${SCRIPT_DIR}/bootstrap.sh"
```

And update its `profiles/` lookup to `"${DOTFILES_DIR}/profiles/${arg}.json"`.

- [ ] **Step 2: Add a root `setup.sh` shim**

Create `setup.sh` at repo root:

```bash
#!/usr/bin/env bash
# Convenience shim — forwards to script/setup.sh
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/script/setup.sh" "$@"
```

```bash
chmod +x setup.sh
```

- [ ] **Step 3: Verify the move didn't break basic invocation**

```bash
./setup.sh 2>&1 | head -5
```

Expected: the usage text prints (proves shim → script/setup.sh → bootstrap.sh path resolution works).

- [ ] **Step 4: Add global flag parsing (`--dry-run`, `--force`)**

Near the top of `script/bootstrap.sh` (after color defs), add:

```bash
DRY_RUN=0
FORCE=0

# strip global flags out of "$@" before dispatch
_args=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    *) _args+=("$a") ;;
  esac
done
set -- "${_args[@]}"
```

Add a helper used by all filesystem mutations:

```bash
run() {  # echo in dry-run, execute otherwise
  if ((DRY_RUN)); then
    echo -e "  ${CYAN}[dry-run]${NC} $*"
  else
    "$@"
  fi
}
```

- [ ] **Step 5: Wire `--force` into conflict resolution**

In `confirm()`, short-circuit when forced:

```bash
confirm() {
    if ((FORCE)); then echo "overwrite"; return; fi
    local prompt="$1" ans
    read -rp "$prompt [s=skip / o=overwrite / b=backup]: " ans
    case "$ans" in
    s | S | skip) echo "skip" ;;
    o | O | overwrite) echo "overwrite" ;;
    b | B | backup) echo "backup" ;;
    *) echo "skip" ;;
    esac
}
```

Replace the direct `ln`/`rm`/`mv` calls inside `symlink_module` with `run ln ...` / `run rm ...` / `run mv ...` so `--dry-run` is honored (manifest writes also guarded by `((DRY_RUN)) || echo ... >>"$mf"`).

- [ ] **Step 6: Add auto directory-folding heuristic**

In `symlink_module`, before the per-file loop, add a pass that folds a top-level target directory when it does not yet exist in `$HOME` and the module owns a single subtree for it. Concretely, for each immediate child path the module would create under `$HOME` (e.g. `.config/<app>`), if that exact target dir does not exist, link the whole source subtree as one symlink and record it as a linked dir (reusing the existing `linked_dirs` skip mechanism):

```bash
# Auto-fold: link a subtree as one dir symlink when target dir is absent.
# Only fold leaf config dirs (…/.config/<app>) to avoid clobbering shared dirs like ~/.config.
auto_fold_candidates() {
  local src_dir="$1"
  find "$src_dir" -mindepth 2 -maxdepth 3 -type d \
    -path '*/.config/*' -prune -print 2>/dev/null \
    | sed "s#^${src_dir}/##"
}
```

For each candidate `rel`, if `[[ ! -e "${TARGET}/${rel}" ]]` and it is not already covered by a declared `directory_links`, treat it like a declared directory link (link + add to `linked_dirs`). Keep the existing declared-`directory_links` loop as the authoritative override.

> Conservative rule: only fold when `${TARGET}/${rel}` does NOT exist. If it exists (even as a real dir), fall through to per-file linking so we never replace a populated user dir.

- [ ] **Step 7: Add `restow`, `adopt`, and `undo profile`**

Add functions:

```bash
restow_module() {
  local module_ref
  module_ref="$(normalize_module_ref "$1")" || return 1
  undo_module "$module_ref" 2>/dev/null || true
  symlink_module "$module_ref" && validate_module "$module_ref"
}

adopt_module() {
  local module_ref src_dir
  module_ref="$(normalize_module_ref "$1")" || return 1
  src_dir="$(module_source_dir "$module_ref")" || return 1
  info "Adopting existing \$HOME files into ${module_ref}"
  while IFS= read -r -d '' src; do
    local rel="${src#"${src_dir}/"}"
    [[ "$rel" == ".bootstrap.json" ]] && continue
    local target="${TARGET}/${rel}"
    if [[ -e "$target" && ! -L "$target" ]]; then
      run cp -a "$target" "$src"
      ok "adopted $rel"
    fi
  done < <(find "$src_dir" -type f -print0)
  symlink_module "$module_ref"
}

undo_profile() {
  local name="$1" profile="${PROFILES_DIR}/${name}.json"
  [[ -f "$profile" ]] || { err "Profile not found: $profile"; return 1; }
  info "Rolling back profile: $name"
  while IFS= read -r module_ref; do
    [[ -z "$module_ref" ]] && continue
    undo_module "$module_ref" || warn "$module_ref undo failed, continuing..."
  done < <(profile_modules "$profile")
  ok "Profile rollback complete"
}
```

- [ ] **Step 8: Add the secrets deploy hook**

Add a function and a CLI case so `bootstrap secrets` (and profile deploys) link the root `secrets/` store + loader:

```bash
SECRETS_DIR="${DOTFILES_DIR}/secrets"

deploy_secrets() {
  [[ -d "$SECRETS_DIR" ]] || { warn "No secrets/ dir"; return 0; }
  ensure_target_parent "${HOME}/.config/sops/secrets.yaml"
  run ln -sf "${SECRETS_DIR}/secrets.yaml" "${HOME}/.config/sops/secrets.yaml"
  ensure_target_parent "${HOME}/.local/script/secrets-load"
  run ln -sf "${SECRETS_DIR}/load.sh" "${HOME}/.local/script/secrets-load"
  ok "secrets linked (sops/secrets.yaml, script/secrets-load)"
}
```

- [ ] **Step 9: Extend `main()` dispatch**

Update the `case` in `main()` to add: `restow)`, `adopt)`, `secrets)`, and `undo profile <name>` handling (when `undo`'s next arg is `profile`, call `undo_profile`). Update `usage()` text to list the new commands and the `--dry-run`/`--force` flags. In `deploy_profile`, call `deploy_secrets` once at the end.

In `setup.sh`, add argument inference so `setup app/fish` ≡ `setup use app/fish` (if the first arg contains `/` and isn't a known subcommand, prefix `use`).

- [ ] **Step 10: Smoke-test everything with `--dry-run`**

```bash
cd /home/atalariq/Repos/dotfiles
./setup.sh --dry-run profile lab 2>&1 | head -40
./script/bootstrap.sh --dry-run secrets 2>&1 | head
./script/bootstrap.sh --dry-run use app/yazi 2>&1 | head -20
```

Expected: `[dry-run]` lines for planned symlinks (including folded `.config/<app>` dirs and the secrets links); no files actually created. Confirm with:

```bash
git status --short  # working tree unchanged by dry-run
```

- [ ] **Step 11: Real round-trip on a throwaway module (non-destructive check)**

```bash
HOME_BAK=$(mktemp -d)
HOME="$HOME_BAK" ./script/bootstrap.sh use app/yazi 2>&1 | tail -10
ls -la "$HOME_BAK/.config/yazi" | head        # symlink(s) present
HOME="$HOME_BAK" ./script/bootstrap.sh undo app/yazi 2>&1 | tail -5
ls -la "$HOME_BAK/.config" 2>/dev/null         # links removed
rm -rf "$HOME_BAK"
```

Expected: links created under the temp HOME, then removed by undo. Real `$HOME` untouched.

- [ ] **Step 12: shellcheck the scripts**

```bash
shellcheck -S warning script/bootstrap.sh script/setup.sh setup.sh secrets/load.sh 2>&1 | head -40 || true
```

Expected: no errors (warnings acceptable; fix anything egregious).

- [ ] **Step 13: Commit**

```bash
git add script setup.sh
git -c commit.gpgsign=false commit -q -m "feat(bootstrap): folding, restow, adopt, undo-profile, dry-run/force; deploy secrets; move to script/"
```

---

### Task 21: install-package.md — compact rewrite from this machine

**Files:**

- Rewrite: `docs/install-package.md`

- [ ] **Step 1: Generate the explicit package lists**

```bash
cd /home/atalariq/Repos/dotfiles
pacman -Qqen | paste -sd' ' -    # native explicit
echo '---'
pacman -Qqem | paste -sd' ' -    # AUR/foreign explicit
```

- [ ] **Step 2: Write the compact doc**

Replace `docs/install-package.md` with a compact reference: a short philosophy line, a minimal-base callout, then two code blocks using the generated lists:

````markdown
# Package Installation

Reference snapshot of explicitly-installed packages on this machine. Not a
blind bootstrap — install what a given machine actually needs.

## Minimal base (for bootstrap)

​`bash
sudo pacman -Syu --needed git bash python fish neovim
​`

## Native (pacman, explicit)

​`bash
sudo pacman -S --needed \
  <output of: pacman -Qqen, wrapped>
​`

## AUR (yay, explicit)

​`bash
yay -S --needed \
  <output of: pacman -Qqem, wrapped>
​`

Regenerate with `pacman -Qqen` / `pacman -Qqem`.
````

Wrap the package lists across multiple `\`-continued lines (~6-8 per line) for readability.

- [ ] **Step 3: Verify no removed-doc references remain**

```bash
grep -n 'ai-tools.md\|keybindings.md\|yazi.md' docs/install-package.md && echo "FIX refs" || echo "clean OK"
```

Expected: `clean OK`.

- [ ] **Step 4: Commit**

```bash
git add docs/install-package.md
git -c commit.gpgsign=false commit -q -m "docs(install-package): compact rewrite from installed packages"
```

---

### Task 22: Context docs overhaul (CONTEXT/AGENTS/CLAUDE) + prune + README

**Files:**

- Rewrite: `CONTEXT.md`, `AGENTS.md`
- Create: `CLAUDE.md`
- Delete: `docs/adr/` (0001-0003), `docs/agents/` (domain, issue-tracker, triage-labels), `docs/keybindings.md`, `docs/ai-tools.md`
- Modify: `README.md`

- [ ] **Step 1: Rewrite CONTEXT.md as a conceptual glossary (no module table)**

Replace `CONTEXT.md` with concept definitions only: Module, Profile, Bootstrap, Validated Symlink Farm, Directory Folding, Autostart, Controller, Secrets Loading, Script Conventions. State explicitly that the module inventory is **not** maintained here — the single source of truth is the filesystem (`config/<category>/<module>`) plus `profiles/*.json`. Keep CLI examples (`app/fish`).

- [ ] **Step 2: Rewrite AGENTS.md as repo-specific guidance**

Replace `AGENTS.md` with sections:

- Repo layout (config/ categories, profiles/, script/, secrets/, docs/).
- How to add / move / retire a module (where files go, update profiles, deploy).
- Deployment commands (`./setup.sh <profile>`, `use`/`restow`/`adopt`/`undo`, `--dry-run`/`--force`).
- Secrets workflow (pointer to `docs/secrets.md`).
- Commit conventions (Conventional Commits).
- **Standing rule (call out prominently):** "On any significant change (new/moved/retired module, new command, changed layout), update `CONTEXT.md`, `AGENTS.md`, and `CLAUDE.md`, and `README.md` if user-facing."
- Note: if AGENTS.md grows large, split topics into `docs/agents/` (escape hatch).

- [ ] **Step 3: Create CLAUDE.md as a thin pointer**

Create `CLAUDE.md`:

```markdown
# CLAUDE.md

This repo's agent guidance lives in AGENTS.md (single source of truth).

@AGENTS.md
```

- [ ] **Step 4: Remove stale docs**

```bash
git rm -r docs/adr docs/agents docs/keybindings.md docs/ai-tools.md
```

- [ ] **Step 5: Update README.md**

- Replace `./setup.sh` references to reflect the root shim still works (no change needed for `./setup.sh laptop`) but mention scripts now live in `script/`.
- Remove the "AI tooling" section's link to the deleted `docs/ai-tools.md` (drop the section or reduce to one line: "AI tool configs are backed up under `config/app/ai-tools/`.").
- In the Architecture doc table, fix entries: drop `docs/keybindings.md`, `docs/ai-tools.md`, `docs/adr/`; update script paths to `script/bootstrap.sh`, `script/setup.sh`; add `secrets/` row.
- Fix stack drift: lazygit now under `app/git`; note both Zed and Neovim are configured editors.
- Do not add module/package tables (keep volatile data out).

- [ ] **Step 6: Verify no dangling references to removed docs**

```bash
cd /home/atalariq/Repos/dotfiles
grep -rn 'docs/adr\|docs/agents\|docs/keybindings\|docs/ai-tools\|docs/yazi' README.md CONTEXT.md AGENTS.md CLAUDE.md 2>/dev/null && echo "FIX refs" || echo "clean OK"
```

Expected: `clean OK`.

- [ ] **Step 7: Commit**

```bash
git add CONTEXT.md AGENTS.md CLAUDE.md README.md docs
git -c commit.gpgsign=false commit -q -m "docs: overhaul context files (CONTEXT/AGENTS/CLAUDE), prune stale docs, update README"
```

---

### Task 23: Final sync — retire imv + leftover staging

**Files:**

- Delete: `config/app/imv/`
- Stage: any remaining unstaged changes (e.g. `profiles/laptop.json` if not yet committed, stray files)

- [ ] **Step 1: Stage imv retirement + profiles + anything left**

```bash
cd /home/atalariq/Repos/dotfiles
git add -A
```

- [ ] **Step 2: Review what remains**

```bash
git status --short
git diff --cached --stat | tail -20
```

Expected: imv deletion, `profiles/laptop.json` (if not already committed), and nothing unexpected. If a file belongs to an earlier concern, unstage and fold it into a fixup of that commit instead.

- [ ] **Step 3: Commit**

```bash
git -c commit.gpgsign=false commit -q -m "chore: retire imv module and sync profile registry"
```

---

### Task 24: Final verification + push

- [ ] **Step 1: Working tree must be clean**

```bash
cd /home/atalariq/Repos/dotfiles
git status --short
```

Expected: empty output (clean tree).

- [ ] **Step 2: Verify chronological log**

```bash
git log --date=short --pretty='%ad %s' origin/main..HEAD
```

Expected: dates ascend from 2025-12-30 (pywal) through 2026-06-17 (today's work) in order.

- [ ] **Step 3: Re-run key verifications end-to-end**

```bash
./setup.sh --dry-run profile laptop 2>&1 | tail -20   # bootstrap healthy
selene config/app/nvim/.config/nvim/lua/core/keymaps.lua  # no vim warnings
sops -d secrets/secrets.yaml >/dev/null && echo "secrets OK"
```

Expected: dry-run plan prints; selene clean; `secrets OK`.

- [ ] **Step 4: Push**

```bash
git push origin main
```

Expected: push succeeds; `git status` shows `up to date with origin/main`.

---

## Self-Review (completed during authoring)

**Spec coverage:** A (nvim) → Tasks 15-16; B (yazi) → Task 17; C (ai-tools) → Task 18; D (bootstrap) → Task 20; E (secrets) → Task 19; F (install-package) → Task 21; G (context docs) → Task 22; H (commits) → Tasks 1-23; obs/imv → Tasks 12/23; moves → Tasks 1,2,7. All spec sections mapped.

**Note on lua_ls:** Per the user's spec edit, lua_ls is intentionally left disabled (lazydev handles the `vim` library) — no task enables it.

**Placeholder scan:** No TBD/TODO; all code blocks contain real content. Package lists in Task 21 are generated at execution time (Step 1) rather than hardcoded — intentional, since the source of truth is `pacman`.

**Type/name consistency:** Helper names (`gc`, `run`, `confirm`, `restow_module`, `adopt_module`, `undo_profile`, `deploy_secrets`, `auto_fold_candidates`) are used consistently; secrets paths (`~/.config/sops/secrets.yaml`, `~/.local/script/secrets-load`) match across Tasks 19 and 20.
