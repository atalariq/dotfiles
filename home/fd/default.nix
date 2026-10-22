{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ fd ];
  xdg.configFile."fd".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fd/config";
}
