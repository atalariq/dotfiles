# mango

Requires Mango at the flake-pinned revision; Noctalia 5.3+.

Manual copy: `config.conf` → `$XDG_CONFIG_HOME/mango/config.conf`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

Linux Wayland only; requires Mango, Noctalia v5, kitty and dbus-update-activation-environment. No downloads or sibling sources. Super+Return opens kitty, Super+Space the launcher, Super+L locks, Super+Shift+E exits. Main settings are native Mango; no unsupported optional include is assumed. Custom keybindings from the legacy config are retained only in the legacy tree.
