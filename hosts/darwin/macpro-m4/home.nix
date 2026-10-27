{ ... }:
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "macpro-m4";
    homeDirectory = "/Users/atalariq";
    stateVersion = "26.05";
  };
  targets.darwin.copyApps.enable = true;
  programs = {
    zsh.enable = true;
  };
  dotfiles = {
    ai.enable = true;
    appearance = {
      enable = true;
      gui = true;
    };
    programs = {
      neovim.enable = true;
      gh.enable = true;
      glab.enable = true;
      kitty.enable = true;
      yazi.enable = true;
      agy.enable = true;
    };
  };
}
