{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ tmux ];
  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/tmux/config";
}
