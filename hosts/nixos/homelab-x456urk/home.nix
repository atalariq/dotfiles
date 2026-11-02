{ ... }:
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "homelab-x456urk";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
  };
  # Headless: the shared CLI bundle is on by default, no appearance or desktop
  # modules are selected.
}
