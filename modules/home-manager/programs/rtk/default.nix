{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.rtk.enable = lib.mkEnableOption "rtk configuration";

  config = lib.mkIf config.dotfiles.programs.rtk.enable {

    home.packages = with pkgs; [ rtk ];
    xdg.configFile."rtk".source = dotfilesLib.source ./config;

  };
}
