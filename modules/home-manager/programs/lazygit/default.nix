{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.lazygit.enable = lib.mkEnableOption "lazygit configuration";

  config = lib.mkIf config.dotfiles.programs.lazygit.enable {

    home.packages = with pkgs; [ lazygit ];
    xdg.configFile."lazygit".source = dotfilesLib.themedDirectory ./config;

  };
}
