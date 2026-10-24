{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.desktop = {
    brave.enable = lib.mkEnableOption "brave tools";
    chrome.enable = lib.mkEnableOption "chrome tools";
    files.enable = lib.mkEnableOption "files tools";
    bitwarden.enable = lib.mkEnableOption "bitwarden tools";
    discord.enable = lib.mkEnableOption "discord tools";
    rofi.enable = lib.mkEnableOption "rofi tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.desktop.brave.enable { home.packages = with pkgs; [ brave-origin ]; })
    (lib.mkIf config.dotfiles.desktop.chrome.enable { home.packages = with pkgs; [ google-chrome ]; })
    (lib.mkIf config.dotfiles.desktop.files.enable {
      home.packages = with pkgs; [
        nautilus
        file-roller
        adwaita-icon-theme
        xdg-utils
        libsecret
        psmisc
      ];
    })
    (lib.mkIf config.dotfiles.desktop.bitwarden.enable {
      home.packages = with pkgs; [ bitwarden-desktop ];
    })
    (lib.mkIf config.dotfiles.desktop.discord.enable { home.packages = with pkgs; [ discord ]; })
    (lib.mkIf config.dotfiles.desktop.rofi.enable { programs.rofi.enable = true; })
  ];
}
