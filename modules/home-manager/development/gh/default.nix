{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.development.gh.enable = lib.mkEnableOption "gh configuration";

  config = lib.mkIf config.dotfiles.development.gh.enable {

    home.packages = with pkgs; [ gh ];
    # gh stores login state beside config.yml; keep that state outside the checkout.
    xdg.configFile."gh/config.yml".source = dotfilesLib.source ./config/config.yml;

  };
}
