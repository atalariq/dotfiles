{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.fastfetch.enable = lib.mkEnableOption "fastfetch configuration";

  config = lib.mkIf config.dotfiles.terminal.fastfetch.enable {

    home.packages = with pkgs; [ fastfetch ];
    xdg.configFile."fastfetch".source = dotfilesLib.themedDirectory ./config;

  };
}
