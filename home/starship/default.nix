{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ starship ];
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/starship/config/starship.toml";
}
