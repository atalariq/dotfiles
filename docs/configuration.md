# Configuration model

## Host choices and reusable features

A host imports the NixOS catalogue; a Home Manager configuration imports the home
catalogue. Importing either catalogue declares options. Individual features use
`lib.mkEnableOption` (default false) and guard their effects with `lib.mkIf`.

```nix
{
  imports = [ /path/to/dotfiles/modules/home-manager ];
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "26.05"; # Use the value appropriate to your installation.
  dotfiles.terminal.bash.enable = true;
  dotfiles.terminal.fish.enable = true;
  dotfiles.terminal.ripgrep.enable = true;
  dotfiles.editors.vim.enable = true;
}
```

A group groups related files. It has no master enable switch: enabling Fish does
not enable Atuin, Starship or the rest of the shell group. Dependencies within a
command belong to its package; dependencies between configured features are
explicit assertions or conditional integration. NixOS services and HM settings
are separate choices, even when they describe the same desktop application.

A new feature belongs in its group, declares one enable option, and places all
packages, files, services and activation effects inside that condition. Register
its module in the group index. Read a neighbouring module before adding another
abstraction; avoid filesystem discovery that silently changes composition.

## Source modes

`dotfiles.deployment.mode = "immutable"` is the default. Native files are copied
into the Nix store, so a generation captures their contents. Rebuild and activate
after editing them. This is the normal mode for reproducible deployments.

For native configuration development:

```nix
{
  dotfiles.deployment.mode = "live";
  dotfiles.deployment.checkout = "/home/alice/src/dotfiles";
}
```

The source helper then links native files to that checkout. Reload the relevant
application after editing. Packages, module options, generated Nix settings,
script wrappers, plugin dependencies and the nvf package still require a rebuild.
Noctalia's settings are Nix-generated, not live TOML/JSON. The optional Fish
`nvim-config` picker uses the checkout path in either mode to edit source; an
immutable installation still needs a rebuild to apply those edits. Use Git to restore live
file edits; generation rollback does not restore them.

Neovim's native Lua runtime follows the selected mode; nvf still owns its plugins
and external tools. Do not edit generated init.lua or run a second plugin manager.

## Runtime state and ownership

Own configuration at file granularity wherever the neighbouring directory also
contains writable state. Examples are GH login state, Codex sessions, Fish
universal variables, Hermes memories and Noctalia runtime settings. Do not link
those parent directories wholesale into the store.

Stylix and its adapters generate the managed application theme files. Noctalia
consumes the selected palette; its template generation is disabled. Edit the
scheme registry or native source and rebuild, rather than editing generated
files. OBS seeds absent configuration and leaves existing profiles writable.

Runtime helper source belongs to its workflow group. The Nix wrapper supplies
its executables through the user profile; there are no root script wrappers.
[Appearance and switching](themes.md) explains the saved theme state.

## Literate source

Write comments that explain intent, visible behaviour and constraints. Ordinary
settings need one or two sentences. A non-obvious decision should name the
problem, rejected alternatives, chosen tradeoff and a link to the longer record
in [decisions.md](decisions.md).

Keep native formats native. Put commentary for JSON or another comment-free
format in its owning Nix module. Do not duplicate a file's contents in Markdown
or introduce a tangling step. Describe verified history as history, and new
choices as decisions made now.
