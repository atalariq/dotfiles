{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [
    fish
    miniserve
  ];
  # Keep Fish's directory writable for fish_variables and runtime state.
  xdg.configFile."fish/config.fish".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fish/config/config.fish";
  xdg.configFile."fish/conf.d".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fish/config/conf.d";
  xdg.configFile."fish/functions".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fish/config/functions";
  xdg.configFile."fish/completions".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/fish/config/completions";
}
