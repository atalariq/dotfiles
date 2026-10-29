# Agentic setup: crit integration per agent

crit itself is a Nix package (via the `llm-agents` input, `crit 0.23.1` at the
time of writing). Its **per-agent integrations are runtime state**, not Nix
declarations: `crit install <agent>` writes plugin files, commands, and skills
into each agent's own config directories under `$HOME`. Rebuilding the system
does not create them, and a fresh machine needs the commands below once per
agent. `CRIT_NO_UPDATE_CHECK=1` is already set by the Home Manager module so
agents never phone home during a session.

## One-time setup (per agent, on each machine)

`bun` (or `npm`) must be on `PATH` for the OpenCode install only — it fetches
the `@opencode/plugin` dependency. Temporary provision is enough:

```sh
nix shell nixpkgs#bun --command crit install opencode --force
crit install github-copilot --force
crit install codex --force
crit install claude-code --force
crit install gemini --force
crit install hermes --force
crit install prompts        # shared finish/story prompt templates → ~/.crit/prompts/
crit install story-prompts  # story-generation template
```

`agy` (Antigravity) has no native crit integration. The generic `prompts`
install above covers it: point agy at `~/.crit/prompts/` templates when
finishing a review, and drive the loop with plain `crit` CLI commands
(`crit`, `crit comment`, `crit share`).

Install order matters for one shared path (see below); `codex` is
deliberately last because its skill variant carries Codex-specific wording
(background tasks, plan mode, `--author 'Codex'`) that Codex actually needs.

## Verify

```sh
crit check
```

Expected output on this machine: the OpenCode V2 plugin
(`~/.config/opencode/plugins/crit/index.ts`, `tui.ts`, `lib/crit-rpc.ts`) is
current, and per-agent skills exist under `~/.agents/skills/`,
`~/.claude/skills/`, `~/.gemini/`, and `~/.hermes/`.

Two findings are **expected noise, not breakage**:

1. **Shared-path collision in `~/.agents/skills/`.** Codex, GitHub Copilot
   (and OpenCode, for `crit-cli`) all install different content to the same
   `crit/SKILL.md` and `crit-cli/SKILL.md` paths — last writer wins, so
   `crit check` always reports the others as outdated. This is a crit-side
   limitation (upstream installs to one shared directory per agent family).
   Re-running `crit install <agent> --force` for the agent you are about to
   use refreshes its variant; functionality is unaffected otherwise.
2. **GitLab provider warning** (`glab-cli/config.yml` permissions): only
   matters if GitLab MR reviews are needed; fix with
   `chmod 600 ~/.config/glab-cli/config.yml` after `glab auth login`.

## What lives where (crit 0.23.1)

| Agent | Integration path |
| --- | --- |
| opencode (v2) | `~/.config/opencode/plugins/crit/` (`index.ts` server plugin + `tui.ts` toast plugin), `~/.config/opencode/commands/crit{,-story}.md` |
| codex / github-copilot | `~/.agents/skills/crit{,-cli,-story}/SKILL.md` (shared paths — see collision note) |
| claude-code | `~/.claude/skills/crit{,-cli,-story}/SKILL.md` |
| gemini | `~/.gemini/skills/`, `~/.gemini/commands/crit*.toml`, `~/.gemini/policies/crit.toml` |
| hermes | `~/.hermes/skills/crit{,-cli,-story}/SKILL.md` |
| agy (manual) | `~/.crit/prompts/` templates + plain `crit` CLI |

Do not delete `~/.agents/skills/crit/SKILL.md`: the OpenCode installer calls
it "obsolete" for OpenCode (which moved to `commands/` + `crit-cli`), but
Codex and Copilot still read that exact path.
