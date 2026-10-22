{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.yt-dlp ];
  xdg.configFile."yt-dlp/config".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/yt-dlp/config/config";
}
