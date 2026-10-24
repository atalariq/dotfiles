{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.media.mpv.enable = lib.mkEnableOption "mpv configuration";

  config = lib.mkIf config.dotfiles.media.mpv.enable {

    home.packages = [ pkgs.mpv ];
    xdg.configFile."mpv".source = dotfilesLib.source ./config;

  };
}
