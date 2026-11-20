{
  config,
  pkgs,
  lib,
  ...
}:
let
  live = config.dotfiles.deployment.mode == "live";
  checkout = config.dotfiles.deployment.checkout;
in
{

  options.dotfiles.programs.cli.gh.enable = lib.mkEnableOption "gh configuration";

  config = lib.mkIf config.dotfiles.programs.cli.gh.enable {

    home.packages = [ pkgs.gh ];
    # gh stores login state beside config.yml; keep that state outside the checkout.
    xdg.configFile."gh/config.yml".source =
      if live then
        config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/home-manager/programs/cli/config/gh/config.yml"
      else
        ./config/gh/config.yml;

  };
}
