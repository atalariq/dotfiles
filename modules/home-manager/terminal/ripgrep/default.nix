{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.ripgrep.enable = lib.mkEnableOption "ripgrep configuration";

  config = lib.mkIf config.dotfiles.terminal.ripgrep.enable {

    home.packages = with pkgs; [ ripgrep ];
    xdg.configFile."ripgrep".source = dotfilesLib.source ./config;

  };
}
