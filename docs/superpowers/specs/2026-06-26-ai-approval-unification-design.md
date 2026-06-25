# AI-tools Approval/Permission Unification (design)

**Date:** 2026-06-26
**Status:** Approved (brainstorm), pending implementation plan
**Scope:** Sub-project D of the dotfiles audit. Reduce repeated approval prompts
for safe commands across the AI-agent approval layers, while keeping a real
safety net for destructive ones.

---

## Goal

Stop safe, everyday commands from prompting for approval in Claude Code and
Hermes, and bring the relevant AI-tool configs under version control. Keep
genuinely destructive commands gated (prompt or block), backed by tirith.

## Background — the three approval layers

1. **Claude Code** (`~/.claude/settings.json` → `config/app/ai-tools/.claude/settings.json`):
   `permissions.allow/deny`; a `PreToolUse` hook runs `rtk hook claude`.
2. **rtk** (`~/.config/rtk/config.toml`): token-optimizing proxy that
   rewrites/filters command output. Not an approval gate.
3. **Hermes** (`~/.hermes/config.yaml`, symlinked into the repo):
   `approvals.mode: smart` (an LLM judges approvals) + `command_allowlist`.
4. **tirith** (`gateway.yaml` + `.tirith/policy.yaml`): dynamic command/URL
   security scanner. Shell hook fail-closed; MCP gateway fail-open.
5. **OpenCode** (`opencode.jsonc`): `permission` block. Already conservative.

**Why prompts happened (diagnosis):** Claude Code checks **each subcommand of a
compound command independently** (`&&`, `||`, `;`, `|`, `&`, newline all split),
and many safe-but-mutating commands (`mkdir`, `cp`, `mv`, `sed`, `cd`, …) were
never allow-listed. So `cd x && rtk wc -l *` prompted on `cd` and `rtk wc`. The
`rtk hook claude` PreToolUse hook is **not** the cause — the permission decision
is on the command, not the hook. Allow-all + targeted ask/deny resolves it; the
hook stays unchanged.

## Decisions (locked during brainstorm)

1. **Claude Code: allow-all bash + 3-tier gating.** `Bash(*)` in `allow`; a
   strengthened `deny` (catastrophic, hard-blocked); a new `ask` tier
   (destructive-but-legit, prompts). Eval order is deny → ask → allow, so the
   broad allow is safe.
2. **Hermes: `smart` + generous `command_allowlist`** (not the nuclear
   `mode: off`, per the user's own dotfiles SKILL.md). Patterns mirror the Claude
   safe set. Hermes' tirith stays fail-closed.
3. **OpenCode: unchanged** (already good).
4. **tirith: unchanged** (already permissive; it's the dynamic backstop).
5. **Track the new AI configs** in the repo (secrets stay in ignored
   `.env`/`auth.json`).
6. **Antigravity: deferred** (config location/mechanism unknown).

Permission syntax confirmed (Claude Code docs): `Bash(x:*)` ≡ `Bash(x *)` (both
enforce a word boundary); `deny` overrides `ask` overrides `allow`; `:*` is
shorthand for a trailing ` *`. Standardize on the `:*` form.

---

## Section 1 — Claude Code `permissions` (3-tier)

### allow

```
Bash(*)
Read
Edit
Write
MultiEdit
Glob
Grep
```

### ask (still prompts — destructive but legitimately needed)

```
Bash(rm:*)
Bash(rmdir:*)
Bash(rtk rm:*)
Bash(sudo:*)
Bash(chmod:*)
Bash(chown:*)
Bash(rtk chmod:*)
Bash(rtk chown:*)
Bash(dd:*)
Bash(truncate:*)
Bash(shred:*)
Bash(kill:*)
Bash(pkill:*)
Bash(killall:*)
Bash(systemctl:*)
Bash(reboot:*)
Bash(shutdown:*)
Bash(poweroff:*)
Bash(git reset --hard:*)
Bash(git clean:*)
Bash(pacman -S:*)
Bash(pacman -R:*)
Bash(yay:*)
Bash(paru:*)
```

### deny (hard-blocked — catastrophic only; preserves current entries)

```
Bash(rm -rf /)
Bash(rm -rf /*)
Bash(rm -fr /)
Bash(rm -fr /*)
Bash(rm -rf ~)
Bash(rm -rf ~/)
Bash(rm -rf ~/*)
Bash(rm -rf /etc:*)
Bash(rm -rf /usr:*)
Bash(rm -rf /var:*)
Bash(rm -rf /boot:*)
Bash(rm -rf /bin:*)
Bash(rm -rf /lib:*)
Bash(sudo rm:*)
Bash(mkfs:*)
Bash(rtk mkfs:*)
Bash(dd of=/dev/:*)
Bash(chmod -R 777 /:*)
Bash(curl * | bash)
Bash(curl * | sh)
Bash(wget * | sh)
Bash(wget * | bash)
Bash(eval *)
Bash(rtk proxy:*)
Bash(git push --force)
Bash(git push -f)
Bash(git push --force-with-lease)
Read(./.env)
Read(./.env.*)
Read(./secrets/**)
```

Notes:

- The old per-command `Bash(rtk <cmd>:*)` entries (15+) are removed — `Bash(*)`
  covers them.
- `ask` rm prompts let a scoped `rm -rf node_modules` be a one-click approve,
  while the absolute-system-root rm forms in `deny` are hard-blocked.
- tirith (PreToolUse `rtk hook claude` path) remains the dynamic third layer for
  anything the static rules miss (e.g. obfuscated pipe-to-shell).
- `additionalDirectories: ["~/Repos"]`, the hooks, model, and plugin settings in
  `settings.json` are unchanged.

---

## Section 2 — Hermes `command_allowlist`

Keep `approvals.mode: smart` (and its `timeout`, `cron_mode: deny`, etc.).
Replace the placeholder `command_allowlist: ["script execution via -e/-c flag"]`
with real glob patterns:

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

`security.tirith_enabled: true` / `tirith_fail_open: false` stays — Hermes blocks
on tirith failure (fail-closed), a stronger gate than the shell hook.

**Implementation caveat:** confirm Hermes' allowlist match semantics (glob on the
command string) during implementation — verify with one `rtk` command in a Hermes
session or `hermes config check` after editing. The patterns above assume
fnmatch-style command-string globs (consistent with the `/usr/bin/*` example in
Hermes' own migration tests).

---

## Section 3 — Config tracking & untouched layers

### Bring under version control (secret-scan first; all clean — secrets live in ignored `.env`/`auth.json`)

- `config/app/ai-tools/.hermes/config.yaml`
- `config/app/ai-tools/.hermes/profiles/*.yaml`
- `config/app/ai-tools/.config/rtk/filters.toml`
- Commit the edited `config/app/ai-tools/.claude/settings.json`
- (`.config/tirith/gateway.yaml` and `.tirith/policy.yaml` are **already
  tracked** — no action.)

### Unchanged (verified already good)

- **OpenCode** `opencode.jsonc`: `external_directory` work-dir allows + `"*":
"ask"`. No change.
- **tirith** `gateway.yaml` / `policy.yaml`: `warn_action: forward`, gateway
  `fail_open: true`, `paranoia: 1`, `strict_warn: false`. No change.
- **rtk hook**: the `PreToolUse` `rtk hook claude` stays — it was not the
  friction cause.

### Deferred

- **Antigravity** — locate its config + permission model in a follow-up; not in
  this sub-project.

---

## Verification

- `config/app/ai-tools/.claude/settings.json` is valid JSON; spot-check that a
  compound safe command (`cd x && rtk wc -l *`) would no longer prompt, and that
  a destructive one (`rm -rf foo`) still prompts (`ask`), and `rm -rf /` is denied.
- `~/.hermes/config.yaml` is valid YAML; `hermes config check` passes; an `rtk`
  command in a Hermes session does not prompt.
- `git status` shows the previously-untracked AI configs now staged; no secrets in
  the committed diffs (`.env`/`auth.json` remain ignored).

## Out of scope

Antigravity; OpenCode changes; tirith tuning; the rtk output-filtering config
(`config.toml` has an unrelated pre-existing dirty change — leave it).
