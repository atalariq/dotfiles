# AI Approval/Permission Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop safe everyday commands from prompting for approval in Claude Code (allow-all bash + a 3-tier ask/deny gate) and Hermes (smart mode + a real command_allowlist), and bring the new AI-tool configs under version control.

**Architecture:** Pure config edits — no code. Claude Code `settings.json` gets `Bash(*)` in `allow`, a new `ask` tier (prompts), and a strengthened `deny` tier (hard block). Hermes `config.yaml` gets a real glob `command_allowlist`. Untracked AI configs are committed (secrets stay in ignored `.env`/`auth.json`). Verification is JSON/YAML validity + behavioral spot-checks; tirith remains the dynamic backstop.

**Tech Stack:** JSON (Claude Code settings), YAML (Hermes config), git, GNU stow.

**Scope:** Sub-project D. Spec: `docs/superpowers/specs/2026-06-26-ai-approval-unification-design.md`. OpenCode/tirith unchanged; Antigravity deferred.

**Branch:** before starting, `cd ~/Repos/dotfiles && git checkout -b feat/ai-approval-unification`.

**Repo path:** `DOTFILES` = `~/Repos/dotfiles`. Note `~/.claude/settings.json` and `~/.hermes/config.yaml` are stow-symlinked to the repo files, so editing the repo file edits the live config.

---

## File Structure

- Modify `config/app/ai-tools/.claude/settings.json` — replace the `permissions` object (allow/ask/deny).
- Modify `config/app/ai-tools/.hermes/config.yaml` — replace the `command_allowlist` block (and bring the file under tracking).
- Track `config/app/ai-tools/.hermes/profiles/*.yaml` and `config/app/ai-tools/.config/rtk/filters.toml`.

---

## Task 1: Claude Code permissions — allow-all + ask/deny tiers

**Files:**

- Modify: `config/app/ai-tools/.claude/settings.json` (the `permissions` object, currently lines ~3–87)

- [ ] **Step 1: Replace the `permissions` object.** In `config/app/ai-tools/.claude/settings.json`, replace the ENTIRE existing `"permissions": { ... }` object (the `allow` array, `deny` array, and `additionalDirectories`, from `"permissions": {` through its matching closing `},` right before `"model":`) with exactly:

```json
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read",
      "Edit",
      "Write",
      "MultiEdit",
      "Glob",
      "Grep"
    ],
    "ask": [
      "Bash(rm:*)",
      "Bash(rmdir:*)",
      "Bash(rtk rm:*)",
      "Bash(sudo:*)",
      "Bash(chmod:*)",
      "Bash(chown:*)",
      "Bash(rtk chmod:*)",
      "Bash(rtk chown:*)",
      "Bash(dd:*)",
      "Bash(truncate:*)",
      "Bash(shred:*)",
      "Bash(kill:*)",
      "Bash(pkill:*)",
      "Bash(killall:*)",
      "Bash(systemctl:*)",
      "Bash(reboot:*)",
      "Bash(shutdown:*)",
      "Bash(poweroff:*)",
      "Bash(git reset --hard:*)",
      "Bash(git clean:*)",
      "Bash(pacman -S:*)",
      "Bash(pacman -R:*)",
      "Bash(yay:*)",
      "Bash(paru:*)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(rm -fr /)",
      "Bash(rm -fr /*)",
      "Bash(rm -rf ~)",
      "Bash(rm -rf ~/)",
      "Bash(rm -rf ~/*)",
      "Bash(rm -rf /etc:*)",
      "Bash(rm -rf /usr:*)",
      "Bash(rm -rf /var:*)",
      "Bash(rm -rf /boot:*)",
      "Bash(rm -rf /bin:*)",
      "Bash(rm -rf /lib:*)",
      "Bash(sudo rm:*)",
      "Bash(mkfs:*)",
      "Bash(rtk mkfs:*)",
      "Bash(dd of=/dev/:*)",
      "Bash(chmod -R 777 /:*)",
      "Bash(curl * | bash)",
      "Bash(curl * | sh)",
      "Bash(wget * | sh)",
      "Bash(wget * | bash)",
      "Bash(eval *)",
      "Bash(rtk proxy:*)",
      "Bash(git push --force)",
      "Bash(git push -f)",
      "Bash(git push --force-with-lease)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "additionalDirectories": [
      "~/Repos"
    ]
  },
```

Leave everything else in `settings.json` (the `hooks`, `model`, `enabledPlugins`, `statusLine`, etc.) unchanged.

- [ ] **Step 2: Validate JSON.**

Run:

```bash
cd ~/Repos/dotfiles
python3 -c "import json; d=json.load(open('config/app/ai-tools/.claude/settings.json')); p=d['permissions']; print('allow',len(p['allow']),'ask',len(p['ask']),'deny',len(p['deny']))"
```

Expected: `allow 7 ask 24 deny 30` (valid JSON; the three tiers present with those counts).

- [ ] **Step 3: Confirm the old per-command rtk entries are gone and the tiers are coherent.**

Run:

```bash
cd ~/Repos/dotfiles
grep -c '"Bash(rtk ' config/app/ai-tools/.claude/settings.json
python3 -c "import json; p=json.load(open('config/app/ai-tools/.claude/settings.json'))['permissions']; assert 'Bash(*)' in p['allow']; assert 'Bash(rm:*)' in p['ask']; assert 'Bash(rm -rf /)' in p['deny']; print('tiers OK')"
```

Expected: the grep prints a small number (only the `rtk rm`/`rtk chmod`/`rtk chown`/`rtk mkfs`/`rtk proxy` entries in ask/deny — i.e. `5`), and `tiers OK`. (The 15+ old `Bash(rtk <tool>:*)` allow entries are gone.)

- [ ] **Step 4: Review the full diff before committing** (settings.json had a pre-existing dirty change — confirm nothing unexpected outside the permissions block).

Run:

```bash
cd ~/Repos/dotfiles
git diff config/app/ai-tools/.claude/settings.json | head -120
```

Expected: changes are within `permissions` (and any pre-existing tweak you recognize). If a surprising unrelated change appears outside permissions that you don't recognize, STOP and report.

- [ ] **Step 5: Commit.**

```bash
cd ~/Repos/dotfiles
git add config/app/ai-tools/.claude/settings.json
git commit -m "feat(claude): allow-all bash with ask/deny tiers; drop per-rtk allows"
```

---

## Task 2: Hermes command_allowlist + bring config under tracking

**Files:**

- Modify: `config/app/ai-tools/.hermes/config.yaml` (the `command_allowlist` block)
- Track: `config/app/ai-tools/.hermes/config.yaml`, `config/app/ai-tools/.hermes/profiles/*.yaml`

- [ ] **Step 1: Secret-scan the Hermes files before tracking them.**

Run:

```bash
cd ~/Repos/dotfiles
grep -rniE "(api_key|token|secret|password)[[:space:]]*[:=][[:space:]]*['\"]?[A-Za-z0-9_-]{16,}" \
  config/app/ai-tools/.hermes/config.yaml config/app/ai-tools/.hermes/profiles/ \
  | grep -vE "_env:|API_KEY\)|: ''|: \"\"" || echo "no secrets found"
```

Expected: `no secrets found`. (Secrets live in `.hermes/.env`/`auth.json`, which the ai-tools `.gitignore` already ignores.) If any real secret value appears, STOP and report — do not commit.

- [ ] **Step 2: Replace the placeholder `command_allowlist`.** In `config/app/ai-tools/.hermes/config.yaml`, replace these two lines:

```yaml
command_allowlist:
  - script execution via -e/-c flag
```

with:

```yaml
command_allowlist:
  - rtk *
  - git status*
  - git diff*
  - git log*
  - git show*
  - git branch*
  - ls *
  - cat *
  - bat *
  - grep *
  - rg *
  - fd *
  - find *
  - echo *
  - printf *
  - wc *
  - head *
  - tail *
  - stat *
  - file *
  - which *
  - tree *
  - du *
  - df *
  - cd *
  - mkdir *
  - mv *
  - cp *
  - touch *
  - ln *
  - mktemp*
  - tee *
  - sed *
  - awk *
  - cut *
  - tr *
  - sort *
  - uniq *
  - jq *
  - xargs *
  - diff *
```

Leave `approvals.mode: smart` and all other keys unchanged.

- [ ] **Step 3: Validate YAML.**

Run:

```bash
cd ~/Repos/dotfiles
python3 -c "import yaml; d=yaml.safe_load(open('config/app/ai-tools/.hermes/config.yaml')); a=d['command_allowlist']; print('allowlist',len(a),'mode',d['approvals']['mode']); assert 'rtk *' in a; assert d['approvals']['mode']=='smart'; print('OK')"
```

Expected: `allowlist 41 mode smart` then `OK`.

- [ ] **Step 4: Verify Hermes accepts the config + confirm match semantics.**

Run:

```bash
hermes config check 2>&1 | tail -20
```

Expected: no errors about `command_allowlist` (config valid). **Match-semantics confirmation (the spec's open caveat):** start a Hermes session and run a harmless `rtk` command (e.g. `rtk ls` or `rtk git status`) and confirm it does NOT prompt for approval. If `rtk *` does NOT suppress the prompt, the allowlist matches the resolved binary path rather than the command string — in that case report back so the patterns can be adjusted (e.g. add the absolute rtk binary path from `command -v rtk`). Do not guess silently.

- [ ] **Step 5: Commit (this also brings the Hermes config + profiles under tracking).**

```bash
cd ~/Repos/dotfiles
git add config/app/ai-tools/.hermes/config.yaml config/app/ai-tools/.hermes/profiles/
git status --short config/app/ai-tools/.hermes/
git commit -m "feat(hermes): real command_allowlist; track hermes config + profiles"
```

Confirm `git status --short` shows the config.yaml and profiles staged as new tracked files (`A`), and that no `.env`/`auth.json`/`sessions/` files are staged.

---

## Task 3: Track rtk filters.toml + final verification

**Files:**

- Track: `config/app/ai-tools/.config/rtk/filters.toml`

- [ ] **Step 1: Confirm filters.toml has no secrets and track it.**

Run:

```bash
cd ~/Repos/dotfiles
cat config/app/ai-tools/.config/rtk/filters.toml | head -20
git add config/app/ai-tools/.config/rtk/filters.toml
git commit -m "chore(rtk): track user-global filters.toml"
```

(filters.toml is the example/global rtk filter config — no secrets.)

- [ ] **Step 2: Final cross-layer sanity check.**

Run:

```bash
cd ~/Repos/dotfiles
echo "--- claude settings valid ---"; python3 -c "import json; json.load(open('config/app/ai-tools/.claude/settings.json')); print('ok')"
echo "--- hermes config valid ---"; python3 -c "import yaml; yaml.safe_load(open('config/app/ai-tools/.hermes/config.yaml')); print('ok')"
echo "--- untracked AI configs now tracked ---"; git ls-files config/app/ai-tools/.hermes/config.yaml config/app/ai-tools/.config/rtk/filters.toml
echo "--- secrets still ignored ---"; git check-ignore config/app/ai-tools/.hermes/.env config/app/ai-tools/.hermes/auth.json 2>/dev/null || echo "(env/auth files absent or ignored)"
```

Expected: both configs valid; `git ls-files` lists the two now-tracked configs; the `.env`/`auth.json` paths are reported as ignored (or absent).

- [ ] **Step 3: Confirm OpenCode + tirith were left untouched** (spec says unchanged).

Run:

```bash
cd ~/Repos/dotfiles
git status --short config/app/ai-tools/.config/opencode/ config/app/ai-tools/.config/tirith/ config/app/ai-tools/.tirith/ | grep -vE '^\?\?' || echo "opencode/tirith unchanged"
```

Expected: `opencode/tirith unchanged` (no modifications staged/unstaged to those, aside from pre-existing untracked items).

---

## Self-Review

**Spec coverage:**

- Claude Code 3-tier allow-all + ask + strengthened deny — Task 1 (full lists verbatim from spec). ✅
- Drop the 15+ per-command `Bash(rtk <cmd>:*)` allows — Task 1 (replaced by `Bash(*)`). ✅
- Hermes `smart` + real `command_allowlist` (mirrors Claude safe set) + match-semantics caveat — Task 2. ✅
- Track new AI configs (hermes config + profiles, rtk filters.toml) with secret-scan — Tasks 2, 3. ✅
- OpenCode/tirith unchanged; rtk hook unchanged — Task 3 verifies. ✅
- Antigravity deferred — out of scope (no task). ✅

**Placeholder scan:** No TBD/TODO; full JSON/YAML content provided; every step has concrete commands + expected output. The Hermes match-semantics check is an explicit verification step (run + report if it fails), not a placeholder. ✅

**Type/name consistency:** Tier counts referenced consistently (allow 7 / ask 24 / deny 30 in Task 1 Step 2 match the listed entries; command_allowlist 42 in Task 2 Step 3 matches the listed patterns). Paths consistent across tasks (`config/app/ai-tools/...`). `approvals.mode: smart` preserved. ✅
