{ config, checkout, ... }:
{
  # NixOS owns the sole Wayland daemon and its capability wrapper.
  xdg.configFile."espanso/config/default.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/espanso/config/default.yml";
  xdg.configFile."espanso/match".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/espanso/config/match";
}
