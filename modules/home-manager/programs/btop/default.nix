{
  config,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.btop.enable = lib.mkEnableOption "btop configuration";

  config = lib.mkIf config.dotfiles.programs.btop.enable {

    programs.btop = {
      enable = true;
      settings = {
        shown_boxes = "cpu mem net proc";
        update_ms = 2000;
        check_temp = true;
        show_battery = true;
        truecolor = true;
      };
    };

  };
}
