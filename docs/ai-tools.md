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
| Hermes Agent | package manager / local binary | `~/.hermes/config.yaml` | provider/model credentials as needed | Primary coding/research agent |
| OpenCode | package manager / local binary | tool-local config + shell env | `OPENCODE_*`, provider keys | Fish completion exists in repo |
| Codex CLI | package manager / local binary | tool-local config | provider auth | Document setup, keep auth local |
| Gemini CLI | package manager / local binary | tool-local config | Google auth / API key | Zed registry integration is enabled |
| Zed agents | Zed app | `~/.config/zed/settings.json` | inherited shell env | Repo currently enables `opencode` and `gemini` agent servers |

## Repo-managed pieces

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
- `agent_servers.gemini`

That means Zed is already prepared to discover those integrations once the binaries/auth are present locally.

## Hermes Agent

### What is in repo
- shell env that helps day-to-day usage
- docs only

### What is local
- `~/.hermes/config.yaml`
- model/provider credentials
- profile-specific memory, skills, cron, plugins

### Suggested install check

```bash
hermes --help
hermes status
```

## OpenCode

### What is in repo
- Fish completions: `config/app/fish/.config/fish/completions/opencode.fish`
- shell env toggle: `OPENCODE_ENABLE_EXA=1`

### What is local
- provider auth
- any machine-local OpenCode config

### Suggested install check

```bash
opencode --help
```

## Codex CLI

### What is in repo
- docs only for now

### What is local
- binary install
- auth/session config

### Suggested install check

```bash
codex --help
```

If the binary name differs on your machine, document that locally or update this page later.

## Gemini CLI

### What is in repo
- Zed agent server entry via registry integration

### What is local
- binary install
- Google auth / API key

### Suggested install check

```bash
gemini --help
```

## Zed integration

The repo-managed Zed settings live at:
- `config/app/zed/.config/zed/settings.json`

After deployment, they land at:
- `~/.config/zed/settings.json`

Current agent-related keys already committed:

```json
{
  "agent_servers": {
    "opencode": { "type": "registry" },
    "gemini": { "type": "registry" }
  }
}
```

## Suggested local secret/env checklist

Put secrets in `~/.config/fish/secrets.yaml` rather than hardcoding them in editor or CLI configs.

Examples of the kind of values that may exist locally:
- `OPENROUTER_API_KEY`
- `OPENCODE_GO_API_KEY`
- provider-specific API keys for Hermes / Codex / Gemini / OpenCode

Exact key names can vary by tool version. Keep the docs here stable and the values local.

## Improvement ideas

- Add small per-tool install snippets once package names are stable enough
- Add a table of which tools read env vars vs config files vs browser auth
- Add a troubleshooting section after the setup settles down
