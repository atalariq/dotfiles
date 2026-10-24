{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.development.lazygit.enable = lib.mkEnableOption "lazygit configuration";

  config = lib.mkIf config.dotfiles.development.lazygit.enable {

    home.packages = with pkgs; [ lazygit ];
    xdg.configFile."lazygit".source = dotfilesLib.themedDirectory ./config;

  };
}
