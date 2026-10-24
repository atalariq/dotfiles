{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.herdr.enable = lib.mkEnableOption "herdr configuration";

  config = lib.mkIf config.dotfiles.terminal.herdr.enable {

    home.packages = [ pkgs.herdr ];
    xdg.configFile."herdr/config.toml".source = lib.mkIf (!config.dotfiles.desktop.appearance.enable) (
      dotfilesLib.source ./config/config.toml
    );

  };
}
