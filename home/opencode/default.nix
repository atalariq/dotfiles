{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ opencode ];
  # Keep the directory writable for local plugins and their dependencies.
  xdg.configFile."opencode/opencode.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/opencode/config/opencode.jsonc";
  xdg.configFile."opencode/cli.json".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/opencode/config/cli.json";
  xdg.configFile."opencode/themes/wana.json".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/opencode/config/themes/wana.json";
}
