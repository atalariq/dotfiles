{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.rmpc ];
  xdg.configFile."rmpc".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/rmpc/config";
}
