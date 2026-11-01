# Native Fish configuration

`config/shell/*.fish` contains the editable path defaults, aliases, abbreviations and
small native functions. Home Manager links each file into `fish/conf.d` under
the XDG config directory. Use `dotfiles.deployment.liveApps = [ "fish" ];` to
link these files to the canonical checkout; immutable mode keeps a source copy
in the Nix store. Other applications in `liveApps` can remain selected.

Validate a changed file with `fish --no-config --no-execute <file>`, then start a
new Fish shell. You can `source <file>` to reload a snippet in an existing shell;
removing a definition from a file does not remove it from that running shell.
Interactive aliases/functions are guarded so noninteractive shells do not load
them. `nvimc` opens the canonical Neovim source picker; it explains when edits
need a rebuild. Home Manager still generates package integrations and Stylix
owns the theme. Do not duplicate `atuin init`, `starship init`, or `direnv hook`
in these files.

History and universal variables stay under Fish's writable runtime directories.
Do not copy them, credentials, or exported login state into `config/`.

## Existing directory symlinks

Before activating individual file links, inspect the parent `fish/conf.d`.
If it is already a directory symlink, preserve it and its target before replacing
the parent with a real directory. Compare its files with these native sources;
retain any additional customization in the backup until it is reviewed. Never
use `force` or replace the entire Fish config directory to resolve this collision.

A reviewed migration first prepares a sibling real directory. Copy every legacy
snippet whose basename is not managed by this module into it, preserving file
attributes. This includes private runtime snippets: retain them outside Git,
without printing or importing their contents. The old theme snippet remains
unmanaged until a separate review demonstrates that it duplicates Stylix.
Verify the retained manifest and content parity. After approval, move the old
symlink to an unused sibling backup name, rename the prepared directory to
`conf.d`, and then separately activate Home Manager. Managed filenames are left
absent for Home Manager to install. Before activation, rollback preserves the
prepared directory under another sibling name and restores the old symlink.
After activation,
preserve the new directory under another unused sibling name before restoring
the old symlink, and review the matching generation rollback separately. History
and universal-variable files live outside this parent and must not be moved.
