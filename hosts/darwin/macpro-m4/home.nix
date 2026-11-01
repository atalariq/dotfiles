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
    programs = {
      development.stacks = [
        "java"
        "kotlin"
        "dart"
      ];
      cli = {
        neovim.enable = true;
        gh.enable = true;
        glab.enable = true;
        yazi.enable = true;
      };
      gui.kitty.enable = true;
      agentic = {
        core.enable = true;
        agy.enable = true;
        agent-browser.enable = true;
        hermes.enable = true;
        opencode.enable = true;
        tokscale.enable = true;
        workmux.enable = true;
      };
      development.mise.enable = true;
    };
    appearance = {
      enable = true;
      gui = true;
    };
  };
}
