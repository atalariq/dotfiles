{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.tmux.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "tmux configuration";
  };

  config = lib.mkIf config.dotfiles.programs.tmux.enable {

    home.packages = with pkgs; [ tmux ];
    xdg.configFile."tmux/tmux.conf".source = dotfilesLib.source ./config/tmux.conf;

  };
}
