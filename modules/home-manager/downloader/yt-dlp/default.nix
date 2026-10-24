{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.downloader.yt-dlp.enable = lib.mkEnableOption "yt-dlp configuration";

  config = lib.mkIf config.dotfiles.downloader.yt-dlp.enable {

    home.packages = [ pkgs.yt-dlp ];
    xdg.configFile."yt-dlp/config".source = dotfilesLib.source ./config/config;

  };
}
