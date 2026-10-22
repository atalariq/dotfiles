{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ lazygit ];
  xdg.configFile."lazygit".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/lazygit/config";
}
