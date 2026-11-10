# Keybindings

Each layer owns a modifier family. A key that a parent layer owns never reaches
the child, so the rule below is the contract that keeps the layers from
fighting.

| Layer | Owner | Modifier family | Notes |
| --- | --- | --- | --- |
| Compositor | Umbriel | `Super` (`Mod`), `Super+Alt`, `Ctrl+Super+Alt` | Launcher, windows, workspaces, screenshots, media keys. |
| Terminal | kitty | `Ctrl+Shift` (`kitty_mod`), `Alt+Shift`, `Ctrl+F1..F12` | Tabs, windows, layouts, kittens. |
| Shell | fish / Atuin / TV | `Ctrl+R`, `Ctrl+T` | History and smart autocomplete. |
| Editor | Neovim | `Space` (leader), then plugin namespaces | `Ctrl+h/j/k/l` are window moves inside Neovim only. |
| Multiplexer | tmux | `Ctrl+b` (prefix) | Panes, windows, copy mode. |
| TUI | television | single keys, `Ctrl+<letter>` not claimed above, `F2-F5`, `F12` | `F2-F5` are preview/layout/source/reload; `F12` edits the selected entry. |

## Rules

- Do not bind plain `Ctrl+<letter>` in kitty or Umbriel: those belong to the
  application inside the terminal (Neovim, television, shell).
- Do not bind `F12` in kitty: television uses it for "edit the selected entry".
  Kitty's session save moved to `Alt+Shift+F12`.
- `F2`-`F5` are television's global actions (preview, layout, cycle sources,
  reload). Channel files must not override them; channel-specific actions use
  `Alt+letter`. Channel shortcuts are `F1`, `F6`, `F7`, `F8`.
- `Ctrl+T` launches television from the shell; inside television it toggles
  remote control. That is intentional, not a conflict.
- `Ctrl+R` is Atuin outside television and "reload source" inside it.

## Quick reference

### Umbriel (`Super`)

- `Super+Return` kitty · `Super+W` browser · `Super+E` launcher (`/emo`)
- `Super+Space` launcher · `Super+V` clipboard · `Super+C` control center
- `Super+H/J/K/L` focus · `Super+Shift+H/J/K/L` move window
- `Super+1..5` workspace · `Super+Shift+1..5` move window to workspace
- `Super+R` resize submap · `Super+G` region submap · `Super+O` overview
- `Super+Shift+F` fullscreen · `Super+Shift+Space` floating
- `Super+Minus`/`Super+Grave` scratchpad · `Super+Escape` session menu
- `Print` region screenshot · `Shift+Print` fullscreen · `Alt+Print` window
- `Super+Alt+R` OBS recording toggle

### kitty (`Ctrl+Shift` = `kitty_mod`)

- `kitty_mod+Return` new window · `kitty_mod+N` new OS window
- `kitty_mod+T` new tab · `kitty_mod+1..8` go to tab
- `kitty_mod+H/J/K/L` neighbouring window · `kitty_mod+F` move window forward
- `kitty_mod+Space` next layout · `kitty_mod+P` command palette
- `Alt+Shift+R` reload config · `Alt+Shift+F12` save session
- `Ctrl+F10` maximize · `Ctrl+F11` fullscreen · `Ctrl+F1` kitty docs

### television

- `Enter` confirm · `Tab` multi-select · `Ctrl+Y` copy · `Ctrl+R` reload
- `Ctrl+S` cycle sources · `Ctrl+T` remote control · `Ctrl+X` action picker
- `Ctrl+O` preview · `Ctrl+H` help · `Ctrl+L` layout · `F12` status bar
- `F2` preview · `F3` layout · `F4` cycle sources · `F5` reload
- Channel shortcuts: `F1` files, `F6` dirs, `F7` env, `F8` OpenCode sessions
- Channel actions use `Alt+letter` (e.g. `Alt+R` run just recipe, `Alt+T`
  terminate process, `Alt+S` stop service) so they never shadow `F2`-`F5`
- `F12` also edits the selected entry in `files`, `git-files`, `dotfiles`,
  `git-diff`, `nvim-config`

### Shell

- `tvf` files · `tvg` git log · `tvd` dotfiles · `tvo` OpenCode sessions ·
  `tvj` just recipes
- `Ctrl+T` smart autocomplete · `Ctrl+R` Atuin history

### Neovim

- `Space` leader · `Space e` Oil · `Space Space` buffers · `Space f f` files
- `Space f g` live grep · `Space g g` Neogit · `Space g s` fugitive status
- `Space h p` preview hunk · `Space h B` blame · `]h`/`[h` next/prev hunk
- `Ctrl+H/J/K/L` window moves · `Ctrl+S` save (normal and insert)
- `jk`/`kj` leave insert mode

### Agent TUIs

- Shared map and vim mode: [agent-keybindings.md](agent-keybindings.md)
- `Enter` submit, `Ctrl+J` newline, `Ctrl+G` editor, `Ctrl+S` stash,
  `Ctrl+D` exit; `Esc` cancels.

### tmux (`Ctrl+b`)

- `Ctrl+b c` new window · `Ctrl+b h/j/k/l` select pane
- `Ctrl+b |` / `Ctrl+b -` split · `Ctrl+b z` zoom · `Ctrl+b r` reload
- `Ctrl+b o` sessionx (sessions/windows) · `Ctrl+b f` floax (scratch pane)
- `Ctrl+b F` tmux-fzf menu · `Ctrl+b y` / `Y` copy selection / whole line
- `Ctrl+b C-s` save session · `Ctrl+b C-r` restore session
