{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.academic = {
    anki.enable = lib.mkEnableOption "anki tools";
    obsidian.enable = lib.mkEnableOption "obsidian tools";
    readest.enable = lib.mkEnableOption "readest tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.academic.anki.enable { home.packages = with pkgs; [ anki ]; })
    (lib.mkIf config.dotfiles.academic.obsidian.enable { home.packages = with pkgs; [ obsidian ]; })
    (lib.mkIf config.dotfiles.academic.readest.enable { home.packages = with pkgs; [ readest ]; })
  ];
}
