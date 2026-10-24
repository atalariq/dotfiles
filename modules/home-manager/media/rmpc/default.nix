{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.media.rmpc.enable = lib.mkEnableOption "rmpc configuration";

  config = lib.mkIf config.dotfiles.media.rmpc.enable {

    home.packages = [ pkgs.rmpc ];
    xdg.configFile."rmpc".source = dotfilesLib.themedDirectory ./config;

  };
}
