{ config, checkout, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "wana";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      check_temp = true;
      show_battery = true;
      truecolor = true;
    };
  };
  xdg.configFile."btop/themes/wana.theme".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/btop/config/themes/wana.theme";
}
