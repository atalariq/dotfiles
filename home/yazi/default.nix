{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [
    yazi
    ouch
    mediainfo
    ffmpeg
    imagemagick
  ];
  xdg.configFile."yazi".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/yazi/config";
}
