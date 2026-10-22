{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.aria2 ];
  xdg.configFile."aria2/aria2.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/aria2/config/aria2.conf";
}
