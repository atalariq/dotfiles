{ pkgs, ... }:
{
  imports = [ ../../../modules/home-manager ];
  home = {
    sessionVariables.DOTFILES_HOST = "wsl-lab";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    packages = [ pkgs.wget ];
  };
  dotfiles.programs.development.stacks = [
    "node"
    "python"
  ];
  targets.genericLinux.enable = true;
}
