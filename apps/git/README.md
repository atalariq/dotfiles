# git

Requires Git 2.40+ (pin: 2.55.0).

Manual copy: `config` → `$XDG_CONFIG_HOME/git/config`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

No identity or credentials are set. Optional `$XDG_CONFIG_HOME/git/config.local.git` is included after shared defaults; use it for user.name/user.email/signing settings, not credentials. Existing ~/.gitconfig may override these XDG settings. Credential helpers and logins remain machine-local. No downloads.
