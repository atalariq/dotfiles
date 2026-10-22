{
  config,
  pkgs,
  checkout,
  ...
}:
{
  xdg.configFile."herdr".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/herdr/config";
}
