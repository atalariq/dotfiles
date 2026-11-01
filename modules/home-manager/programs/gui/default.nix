# GUI applications are host-local. This category is a library of opt-in
# modules, not a cross-host bundle: NixOS x13 uses Home Manager packages and
# config, macOS uses Homebrew casks, and headless hosts install nothing.
#
# There is deliberately no dotfiles.programs.gui.enable. Select apps
# individually, or use gui/workstation.nix as a convenience aggregate.
{ lib, ... }:
{
  imports = import ../_import-category.nix {
    inherit lib;
    dir = ./.;
  };
}
