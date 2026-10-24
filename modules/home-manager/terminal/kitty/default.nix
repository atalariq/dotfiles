{
  config,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.kitty.enable = lib.mkEnableOption "kitty configuration";

  config = lib.mkIf config.dotfiles.terminal.kitty.enable {

    assertions = [
      {
        assertion = config.dotfiles.terminal.fish.enable;
        message = "Kitty's interactive shell requires dotfiles.terminal.fish.enable.";
      }
    ];
    home.packages = [
      pkgs.kitty
      pkgs.fish
    ];
    xdg.configFile."kitty/kitty.conf".source = dotfilesLib.source ./config/kitty.conf;
    xdg.configFile."kitty/theme.conf".source = lib.mkIf (!config.dotfiles.desktop.appearance.enable) (
      dotfilesLib.source ./config/theme.conf
    );
    xdg.configFile."kitty/sessions".source = dotfilesLib.source ./config/sessions;

  };
}
