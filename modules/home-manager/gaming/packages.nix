{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.gaming = {
    steam.enable = lib.mkEnableOption "steam tools";
    osu.enable = lib.mkEnableOption "osu tools";
    doom.enable = lib.mkEnableOption "doom tools";
    mcpe.enable = lib.mkEnableOption "mcpe tools";
    gba.enable = lib.mkEnableOption "gba tools";
    ps1.enable = lib.mkEnableOption "ps1 tools";
    snes.enable = lib.mkEnableOption "snes tools";
    ps2.enable = lib.mkEnableOption "ps2 tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.gaming.steam.enable { home.packages = with pkgs; [ steam ]; })
    (lib.mkIf config.dotfiles.gaming.osu.enable { home.packages = with pkgs; [ osu-lazer ]; })
    (lib.mkIf config.dotfiles.gaming.doom.enable { home.packages = with pkgs; [ gzdoom ]; })
    (lib.mkIf config.dotfiles.gaming.mcpe.enable { home.packages = with pkgs; [ mcpelauncher-ui-qt ]; })
    (lib.mkIf config.dotfiles.gaming.gba.enable { home.packages = with pkgs; [ mgba ]; })
    (lib.mkIf config.dotfiles.gaming.ps1.enable { home.packages = with pkgs; [ mednafen ]; })
    (lib.mkIf config.dotfiles.gaming.snes.enable { home.packages = with pkgs; [ snes9x ]; })
    (lib.mkIf config.dotfiles.gaming.ps2.enable { home.packages = with pkgs; [ pcsx2 ]; })
  ];
}
