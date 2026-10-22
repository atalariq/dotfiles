{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ tirith ];
  home.file.".tirith/policy.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/tirith/config/tirith/policy.yaml";
  xdg.configFile."tirith/gateway.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/tirith/config/gateway.yaml";
}
