{ pkgs, ... }:
let
  apps = import ./apps.nix { inherit pkgs; };
in
{
  imports = [ ../../../modules/home-manager ];
  home = {
    sessionVariables.DOTFILES_HOST = "wsl-lab";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    packages = apps.cli;
  };
  dotfiles = {
    deployment.liveApps = [ "tmux" ];
    programs.development.stacks = apps.stacks;
  };
  targets.genericLinux.enable = true;
}
