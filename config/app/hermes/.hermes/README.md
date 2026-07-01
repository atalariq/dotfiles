# Hermes Agent Config

## Tracked files

| File | Source | Contains secrets? |
|------|--------|-------------------|
| `config.yaml` | `~/.hermes/config.yaml` | No (references .env vars) |
| `profiles/*.yaml` | `~/.hermes/profiles/<name>/config.yaml` | No |
| `SOUL.md` | `~/.hermes/SOUL.md` | No |

## NOT tracked (in .gitignore)

- `.env` — API keys (`OPENCODE_GO_API_KEY`, `DEEPSEEK_API_KEY`, etc.)
- `auth.json` — ephemeral OAuth tokens, credential pools
- `state.db`, `sessions/`, `logs/` — runtime state
- `skills/` — managed by Hermes internally (too volatile)

## Provider stack (post-codex)

After OpenAI Codex subscription expired, moved to:

- **opencode-go** — primary for cheap/fast models (DS4-flash, GLM-5, etc.)
- **deepseek** — direct API for reasoning-heavy tasks (DS4-pro)
- **openrouter** — fallback/access to broader model range

Profile allocation:

| Profile | Primary provider | Default model |
|---------|-----------------|---------------|
| default | deepseek | deepseek-v4-flash |
| researcher | deepseek | deepseek-v4-pro |
| reviewer | openrouter | deepseek/deepseek-v4-pro |
| writer | opencode-go | deepseek-v4-flash |
| fixer | deepseek | deepseek-chat |

## Sync

Use `./sync.sh {push|pull|link}`:

```bash
# One-time backup
./sync.sh push

# Symlink for live git tracking (edits auto-sync)
./sync.sh link

# Restore from dotfiles
./sync.sh pull
```
