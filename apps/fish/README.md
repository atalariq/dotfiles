# fish

Requires Fish 3.6+ (pin: 4.9.3).

Manual copy: `config.fish` → `$XDG_CONFIG_HOME/fish/config.fish`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

Optional Starship, zoxide and direnv are initialized only in interactive shells and only when installed. No downloads. Put optional machine preferences in `fish/config.local.fish`; it loads last. No sibling dotfiles are sourced.
