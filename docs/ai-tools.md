# AI Tools Setup

Current AI/dev-agent setup in this dotfiles repo.

This page documents **what is committed**, **what stays machine-local**, and **which env vars/secrets are expected**.

## Ground rules

- Never commit live API keys or tokens.
- Commit portable config and shell glue only.
- Keep secrets in `~/.config/fish/secrets.yaml` via the repo source at `config/app/fish/.config/fish/secrets.yaml`.
- See [`docs/secrets.md`](./secrets.md) for secret management.

## Current state summary

| Tool | Install path | Config path | Secrets / env | Notes |
| --- | --- | --- | --- | --- |
| OpenCode | package manager / local binary | `~/.config/opencode/` + shell env | `OPENCODE_*`, provider keys | Curated backup now committed under `config/app/ai-tools/` |
| Codex CLI | package manager / local binary | `~/.codex/` | provider auth | Curated backup now committed under `config/app/ai-tools/`, secrets redacted |
| Hermes Agent | package manager / local binary | `~/.hermes/config.yaml` | provider/model credentials as needed | Documented only, not backed up in repo |
| Zed agents | Zed app | `~/.config/zed/settings.json` | inherited shell env | Repo currently enables `opencode` only |
| Neovim AI | not configured | n/a | n/a | Current `config/app/nvim` stays AI-plugin-free |

## Repo-managed pieces

Besides Fish + Zed glue, this repo now keeps a **curated backup layer** for the AI CLIs themselves:

- `config/app/ai-tools/.config/opencode/`
- `config/app/ai-tools/.codex/`

Interpretation: this is a recovery/safety-net backup for a broken machine or fresh install, not an attempt to commit auth/session state.

Intentionally excluded:
- auth/session tokens
- sqlite/db/cache/history files
- temp files and logs
- bulky downloaded extension/plugin caches
- Codex per-project trust state and hook trust hashes

For Codex specifically, inline secrets were redacted in the committed backup on purpose. Refill them locally after restore.

### Fish env

Relevant repo files:
- `config/app/fish/.config/fish/conf.d/00-dev.fish`
- `config/app/fish/.config/fish/secrets.yaml`
- `config/app/fish/.config/fish/completions/opencode.fish`

Current non-secret env toggles already committed:
- `HERMES_TUI=0`
- `OPENCODE_ENABLE_EXA=1`
- `OPENSPEC_TELEMETRY=0`
- `MNEMOSYNE_DATA_DIR="$HOME/.mnemosyne/data"`

### Zed

Relevant repo file:
- `config/app/zed/.config/zed/settings.json`

Current committed state includes:
- `agent_servers.opencode`

That means Zed is already prepared to discover those integrations once the binaries/auth are present locally.

Neovim is intentionally different right now: no Copilot/Avante/CodeCompanion-style plugin is configured yet. That keeps the editor minimal, but it also means all AI usage currently happens through terminal CLIs or Zed rather than inside Neovim buffers.

## Hermes Agent

Hermes stays part of the workflow, but **not** as a repo-backed config module right now.

### What is in repo
- shell env that helps day-to-day usage
- docs like this page

### What is local
- `~/.hermes/config.yaml`
- `SOUL.md`
- model/provider credentials
- profile-specific memory, skills, cron, plugins, scripts, and presets

### Suggested install check

```bash
hermes --help
hermes status
```

## OpenCode

### What is in repo
- Fish completions: `config/app/fish/.config/fish/completions/opencode.fish`
- shell env toggle: `OPENCODE_ENABLE_EXA=1`
- curated backup under `config/app/ai-tools/.config/opencode/` including:
  - `opencode.jsonc`
  - `tui.jsonc`
  - `dcp.jsonc`
  - instructions/theme/plugin glue

### What is local
- provider auth
- transient notifier state
- `node_modules/` and other reinstallable package cache

### Suggested install check

```bash
opencode --help
```

## Codex CLI

### What is in repo
- curated backup under `config/app/ai-tools/.codex/` including:
  - `config.toml` (sanitized)
  - `AGENTS.md`
  - `RTK.md`
  - `hooks.json` (empty baseline, no machine-specific commands)
  - `rules/default.rules`

### What is local
- binary install
- auth/session config
- sqlite/history/cache state
- per-project trust decisions
- hook trust hashes / machine-specific command hooks

### Suggested install check

```bash
codex --help
```

If the binary name differs on your machine, document that locally or update this page later.

## Zed integration

The repo-managed Zed settings live at:
- `config/app/zed/.config/zed/settings.json`

After deployment, they land at:
- `~/.config/zed/settings.json`

Current agent-related keys already committed:

```json
{
  "agent_servers": {
    "opencode": { "type": "registry" }
  }
}
```

## Suggested local secret/env checklist

Put secrets in `~/.config/fish/secrets.yaml` rather than hardcoding them in editor or CLI configs.

Examples of the kind of values that may exist locally:
- `OPENROUTER_API_KEY`
- `OPENCODE_GO_API_KEY`
- provider-specific API keys for Hermes / Codex / OpenCode

Exact key names can vary by tool version. Keep the docs here stable and the values local.

## Improvement ideas

- Add small per-tool install snippets once package names are stable enough
- Add a table of which tools read env vars vs config files vs browser auth
- Add a troubleshooting section after the setup settles down
