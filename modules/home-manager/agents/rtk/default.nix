{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.agents.rtk.enable = lib.mkEnableOption "rtk configuration";

  config = lib.mkIf config.dotfiles.agents.rtk.enable {

    home.packages = with pkgs; [ rtk ];
    xdg.configFile."rtk".source = dotfilesLib.source ./config;

  };
}
