{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ fzf ];
  xdg.configFile."fzf".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fzf/config";
}
