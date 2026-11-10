# Agent keybindings

The interactive agent TUIs share a small common keyboard contract. Fresh
profiles receive it from the Home Manager seeds; existing profiles are merged
with missing keys only, so local overrides keep winning.

| Action | Key | Codex | Claude Code | OpenCode | Hermes TUI |
| --- | --- | --- | --- | --- | --- |
| Submit | `Enter` | yes | yes | yes | yes |
| New line | `Ctrl+J` / `Shift+Enter` | yes | yes | yes | yes |
| External editor | `Ctrl+G` | yes | yes | yes | yes |
| Stash prompt | `Ctrl+S` | — | yes | yes | yes |
| Exit | `Ctrl+D` | yes | yes | yes | yes |
| History | `Up` / `Down` | yes | yes | yes | yes |
| Cancel / close | `Esc` | yes | yes | yes | yes |
| Interrupt | `Ctrl+C` | yes | yes | clears input | clears input |

`Ctrl+C` is intentionally tool-specific: Claude/Codex interrupt the running
turn, while OpenCode/Hermes first clear the composer. `Esc` remains the
non-destructive close/cancel key.

## Vim mode

- **Codex:** `tui.vim_mode_default = true`; enter normal mode with `Esc`, insert
  with `i`.
- **Claude Code:** `editorMode = "vim"` in `settings.json`; `jj` maps to `Esc`.
- **Hermes:** `display.vim_mode: true`; run `hermes config set
  display.vim_mode true` once on an existing profile.
- **OpenCode:** no native vim mode. The shared `cli.json` enables
  [`@leohenon/opencode-vim-plugin`](https://github.com/leohenon/opencode-vim-plugin)
  with normal mode as the initial mode. The plugin is installed by OpenCode from
  npm at runtime, so it is not pinned by `flake.lock`; review it like any other
  editor plugin.

## OpenCode

`~/.config/opencode/cli.json` is owned by OpenCode. The seeded/merged fragment
sets:

```json
{
  "keybinds": {
    "input.line.home": "home,ctrl+a",
    "input.line.end": "end,ctrl+e",
    "input.buffer.home": "ctrl+home",
    "input.buffer.end": "ctrl+end",
    "input.newline": "shift+return,ctrl+j",
    "prompt.editor": "ctrl+g",
    "prompt.stash": "ctrl+s",
    "prompt.history.previous": "up",
    "prompt.history.next": "down"
  }
}
```

`Home`/`End` move by line like the other tools; buffer start/end moved to
`Ctrl+Home`/`Ctrl+End`.

## Codex

The seed adds:

```toml
tui.vim_mode_default = true

[tui.keymap.global]
open_external_editor = "ctrl-g"

[tui.keymap.composer]
insert_newline = ["shift-enter", "ctrl-j"]
```

Use `/keymap` inside Codex to inspect or change the active map.

## Claude Code

The seed adds `editorMode = "vim"` and `vimInsertModeRemaps = { jj = "<Esc>" }`.
Defaults already cover submit, newline, editor, stash, exit and history.
`~/.claude/keybindings.json` remains optional for further remapping.

## Hermes

Hermes keybindings are mostly fixed. The recent `display.vim_mode` setting
covers composer editing; other shortcuts are documented in
`hermes --help` and `/help`.
