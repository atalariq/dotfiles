# nvim

Requires Neovim 0.10+ (pin: 0.12.6).

Manual copy: this whole folder → `$XDG_CONFIG_HOME/nvim`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

No plugins or first-run downloads. Lua `init.local.lua` loads last if present. Persistent undo, caches and swap use Neovim/XDG state, outside this folder. Language servers and formatters come from the project shell. Add a real plugin-manager lockfile if adding plugins.
