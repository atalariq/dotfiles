{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ rtk ];
  xdg.configFile."rtk".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/rtk/config";
}
