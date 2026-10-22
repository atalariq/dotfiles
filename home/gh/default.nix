{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ gh ];
  # gh stores login state beside config.yml; keep that state outside the checkout.
  xdg.configFile."gh/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/gh/config/config.yml";
}
