{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.starship.enable = lib.mkEnableOption "starship configuration";

  config = lib.mkIf config.dotfiles.terminal.starship.enable {

    home.packages = with pkgs; [ starship ];
    xdg.configFile."starship.toml".source = dotfilesLib.source ./config/starship.toml;

  };
}
