# Standalone Neovim: the same kernel the Home Manager wrapper imports, so
# `nix run .#neovim` cannot drift from the installed editor.
{
  inputs,
  pkgs,
  # Standalone has no checkout to link, so the store copy of the live tree is
  # the default.
  runtime ? ./runtime,
  # The portable output is minimal and ASCII-friendly: any host with Nix gets
  # a working editor, Nerd Font or not.
  nerdFont ? false,
  profile ? "minimal",
  # The full profile needs a stack list for nvf's language modules. Defaults to
  # the primary workstation's set.
  stacks ? [
    "node"
    "bun"
    "python"
    "go"
    "rust"
    "cc"
    "php"
    "vue"
    "sql"
  ],
}:
let
  lib = pkgs.lib;
  nvfPlugins = import ./plugins.nix { inherit pkgs profile; };
  # Language modules only exist in the full profile; importing langs.nix in
  # minimal would pull LSP servers and formatters back in.
  langs = lib.optionals (profile == "full") [
    (import ./langs.nix { inherit stacks; })
  ];
in
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    (import ./nvf.nix { inherit runtime nerdFont profile; })
    nvfPlugins.module
    (import ./runtime-layer.nix { inherit runtime; })
  ]
  ++ langs;
}).neovim
