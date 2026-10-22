{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ ripgrep ];
  xdg.configFile."ripgrep".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/ripgrep/config";
}
