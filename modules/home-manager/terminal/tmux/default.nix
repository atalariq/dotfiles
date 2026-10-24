{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.tmux.enable = lib.mkEnableOption "tmux configuration";

  config = lib.mkIf config.dotfiles.terminal.tmux.enable {

    home.packages = with pkgs; [ tmux ];
    xdg.configFile."tmux/tmux.conf".source = dotfilesLib.source ./config/tmux.conf;

  };
}
