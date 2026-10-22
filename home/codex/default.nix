{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.codex ];
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/codex/config/config.toml";
}
