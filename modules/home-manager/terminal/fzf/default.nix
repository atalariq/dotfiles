{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.fzf.enable = lib.mkEnableOption "fzf configuration";

  config = lib.mkIf config.dotfiles.terminal.fzf.enable {

    home.packages = with pkgs; [ fzf ];
    xdg.configFile."fzf/theme.opts" = lib.mkIf (!config.dotfiles.desktop.appearance.enable) {
      source = dotfilesLib.source ./config/theme.opts;
    };

  };
}
