{ pkgs, ... }:
let
  apps = import ./apps.nix { inherit pkgs; };
in
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    packages = apps.cli;
    sessionVariables.DOTFILES_HOST = "macpro-m4";
    homeDirectory = "/Users/atalariq";
    stateVersion = "26.05";
  };
  targets.darwin.copyApps.enable = true;
  programs = {
    zsh.enable = true;
  };
  dotfiles = {
    programs = {
      development.stacks = apps.stacks;
      cli = {
        neovim.enable = true;
        gh.enable = true;
        yazi.enable = true;
      };
      gui.kitty.enable = true;
      agentic = {
        core.enable = true;
        agent-browser.enable = true;
        hermes.enable = true;
        opencode.enable = true;
      };
      development.mise.enable = true;
    };
    appearance = {
      enable = true;
      gui = true;
    };
  };
}
