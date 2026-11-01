{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.btop;
in
{
  options.dotfiles.programs.cli.btop = {
    enable = lib.mkEnableOption "btop";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.btop;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      inherit (cfg) package;
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
