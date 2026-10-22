{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ fastfetch ];
  xdg.configFile."fastfetch".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fastfetch/config";
}
