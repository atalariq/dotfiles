{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.fd.enable = lib.mkEnableOption "fd configuration";

  config = lib.mkIf config.dotfiles.terminal.fd.enable {

    home.packages = with pkgs; [ fd ];
    xdg.configFile."fd".source = dotfilesLib.source ./config;

  };
}
