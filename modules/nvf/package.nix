# Standalone Neovim: the same kernel the Home Manager wrapper imports, so
# `nix run .#neovim` cannot drift from the installed editor.
{
  inputs,
  pkgs,
  # Standalone has no checkout to link, so the store copy of the live tree is
  # the default.
  runtime ? ./runtime,
}:
let
  stacks = [
    "node"
    "bun"
    "python"
    "go"
    "rust"
    "cc"
    "php"
    "vue"
    "sql"
  ];
  nvfPlugins = import ./plugins.nix { inherit pkgs; };
in
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    (import ./nvf.nix { inherit runtime; })
    nvfPlugins.module
    (import ./runtime-layer.nix { inherit runtime; })
    # Standalone default = the x13 stack set (minus the dotfiles-specific
    # editor languages the host opts into), so `nix run .#neovim` matches the
    # primary workstation. Hosts override through their `programs.development.stacks`.
    (import ./langs.nix { inherit stacks; })
  ];
}).neovim
