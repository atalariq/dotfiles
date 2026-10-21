# Original configuration ownership

The authoritative files are `config/app`, `config/desktop/mango` and explicitly
mapped `config/misc/scripts`. The manifest and Home Manager link these original
files directly. Fish functions, aliases and completions; Neovim vim.pack setup,
actual plugin lock and snippets; Yazi plugins, flavors and keymaps; Git settings;
and Mango split configuration remain the owner's configuration.

Compatibility fixes preserve preferences: Mango option renames with three removed
options commented; Noctalia v5 IPC and systemd-owned portal/Polkit startup;
Fish optional startup guards; the renamed Neovim kitehost import and parser tools;
and Yazi plugin naming and quit context. Screenshot helpers declare their native
dependencies, including Indonesian/English OCR. Keyboard backlight uses brightnessctl.

Generated placeholders under apps/, Niri, the old setup/bootstrap scripts and
obsolete setup completion were archived then removed. Other original modules
are retained for future devices. Nix store generations remain available for rollback.

Restoration backup: `/home/atalariq/dotfiles-before-restoration-eifp5fup`.
It holds retired sources, previous links, moved live conflicts and metadata.
The older backup `/home/atalariq/dotfiles-before-v1-hyheuj0j` is retained too.
Live links now resolve to the original checkout. Package/service changes require
the final reviewed NixOS output; see validation.md for its status.

## Later replacement from the external SSD

Replace/edit files under the same config/app/<app> or config/desktop/mango paths.
Directory links expose added child files automatically. File mappings need a new
manifest entry for additional files. Keep Fish universal variables, caches,
credentials, local overrides and Noctalia GUI state out of version control.
Reload the affected app after editing. Nix rollback changes packages/services;
recover live config contents separately with Git or the backup.
