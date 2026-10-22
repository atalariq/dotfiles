{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ bat ];
  xdg.configFile."bat".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/bat/config";
}
