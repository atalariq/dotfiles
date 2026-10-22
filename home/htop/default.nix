{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.htop ];
  xdg.configFile."htop/htoprc".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/htop/config/htoprc";
}
