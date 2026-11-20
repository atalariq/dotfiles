{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.cli.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf config.dotfiles.programs.cli.btop.enable {
    programs.btop = {
      enable = true;
      settings = {
        shown_boxes = "cpu mem net proc";
        update_ms = 2000;
        check_temp = true;
        show_battery = true;
        truecolor = true;
        vim_keys = true;
        rounded_corners = true;
        proc_gradient = true;
        proc_sorting = "cpu lazy";
        mem_graphs = true;
        show_io_stat = true;
        io_mode = true;
        net_download = 100;
        net_upload = 100;
      };
    };
  };
}
