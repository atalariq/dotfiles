{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.rmpc.enable = lib.mkEnableOption "rmpc configuration";

  config = lib.mkIf config.dotfiles.programs.rmpc.enable {

    home.packages = [ pkgs.rmpc ];
    xdg.configFile."rmpc".source = dotfilesLib.themedDirectory ./config;

  };
}
