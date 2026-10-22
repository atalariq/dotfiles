{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.claude-code ];
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/claude/config/settings.json";
  home.file.".claude/script".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/claude/config/script";
}
