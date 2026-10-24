{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.mpv.enable = lib.mkEnableOption "mpv configuration";

  config = lib.mkIf config.dotfiles.programs.mpv.enable {

    home.packages = [ pkgs.mpv ];
    xdg.configFile."mpv".source = dotfilesLib.source ./config;

  };
}
