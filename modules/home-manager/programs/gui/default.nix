# GUI applications are host-owned: environment.systemPackages on NixOS,
# Homebrew casks on macOS, nothing on headless hosts. This category contains
# only the modules that own configuration, a service or a profile bridge; it
# never installs the application package itself.
#
# There is deliberately no dotfiles.programs.gui.enable: select the modules a
# host needs, and put the package in that host's apps.nix.
{ lib, ... }:
{
  imports = import ../_import-category.nix {
    inherit lib;
    dir = ./.;
  };
}
