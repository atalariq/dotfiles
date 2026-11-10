{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.cli.gh.enable = lib.mkEnableOption "gh configuration";

  config = lib.mkIf config.dotfiles.programs.cli.gh.enable {

    home.packages = [ pkgs.gh ];
    # gh stores login state beside config.yml; keep that state outside the checkout.
    xdg.configFile."gh/config.yml".source = dotfilesLib.source ./config/gh/config.yml;

  };
}
