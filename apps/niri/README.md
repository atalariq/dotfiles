# niri

Requires Niri 26.04+ and Noctalia 5.3+.

Manual copy: `config.kdl` → `$XDG_CONFIG_HOME/niri/config.kdl`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

Linux Wayland only; requires Niri, Noctalia and kitty. No downloads or sibling sources. Super+Return opens kitty, Super+Space the launcher, Super+L locks, arrows focus windows/columns, Shift+arrows move them. Run niri validate -c config.kdl after editing. No absent local include is assumed.
