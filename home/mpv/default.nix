{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.mpv ];
  xdg.configFile."mpv".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/mpv/config";
}
