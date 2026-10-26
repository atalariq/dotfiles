{ pkgs, ... }:
{
  imports = [ ../../../modules/home-manager/common ];
  home = {
    sessionVariables.DOTFILES_HOST = "wsl-lab";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    packages = [ pkgs.wget ];
  };
  targets.genericLinux.enable = true;
}
