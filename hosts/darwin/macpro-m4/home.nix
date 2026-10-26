{ pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/common
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "macpro-m4";
    homeDirectory = "/Users/atalariq";
    stateVersion = "26.05";
    packages = with pkgs; [
      (callPackage ../../../modules/home-manager/programs/pen/package.nix { })
    ];
  };
  targets.darwin.copyApps.enable = true;
  programs = {
    delta.enable = true;
    kitty.enable = true;
    yazi.enable = true;
  };
  dotfiles = {
    appearance = {
      enable = true;
      gui = true;
    };
    programs = {
      neovim.enable = true;
      gh.enable = true;
      lazygit.enable = true;
      codex.enable = true;
      claude.enable = true;
      opencode.enable = true;
    };
  };
}
