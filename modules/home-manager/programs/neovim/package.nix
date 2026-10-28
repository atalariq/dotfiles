# Standalone Neovim: the same nvf module the Home Manager module imports, so
# `nix run .#neovim` cannot drift from the installed editor.
{
  inputs,
  pkgs,
  # Standalone has no checkout to link, so the store copy of the live tree is
  # the default.
  runtime ? ./runtime,
}:
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    ./nvf.nix
    (import ./plugins.nix { inherit pkgs inputs; })
    (import ./runtime-layer.nix { inherit runtime; })
  ];
}).neovim
