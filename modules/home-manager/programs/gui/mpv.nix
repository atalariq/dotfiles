{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.gui.mpv.enable = lib.mkEnableOption "mpv configuration";

  config = lib.mkIf config.dotfiles.programs.gui.mpv.enable {

    home.packages = [ pkgs.mpv ];
    xdg.configFile."mpv".source = dotfilesLib.source ./config/mpv;

  };
}
