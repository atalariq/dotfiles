# noctalia

Requires Noctalia 5.3.0 (pinned).

Manual copy: `config.toml` → `$XDG_CONFIG_HOME/noctalia/config.toml`. If XDG_CONFIG_HOME is unset, use `~/.config`.
Copy the listed files (or entire folder for Neovim) without needing this repository.

Linux Wayland only. The compositor starts Noctalia. Hand-written *.toml files are loaded alphabetically; put later overrides in zz.local.toml. GUI settings in $XDG_STATE_HOME/noctalia/settings.toml take precedence and remain unmanaged. Runtime state, plugins, credentials and fingerprint enrollment are not deployed. No plugins or automatic downloads are configured. PAM login and a supported fingerprint daemon are needed for fingerprint unlock.

The shared configuration enables Noctalia’s native Polkit authentication agent.
This provides authorization dialogs for actions such as fingerprint enrollment;
keep other desktop Polkit agents disabled to avoid duplicate registrations.
