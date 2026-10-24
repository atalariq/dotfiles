{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.aria2.enable = lib.mkEnableOption "aria2 configuration";

  config = lib.mkIf config.dotfiles.programs.aria2.enable {

    home.packages = [ pkgs.aria2 ];
    xdg.configFile."aria2/aria2.conf".source = dotfilesLib.source ./config/aria2.conf;

  };
}
