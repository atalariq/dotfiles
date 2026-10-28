{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.terminal.enable = lib.mkEnableOption "the terminal-tools package bundle";

  # Optional CLI/TUI tools that are useful but not part of the every-host core.
  config = lib.mkIf config.dotfiles.programs.terminal.enable {
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

    programs.fastfetch = {
      enable = true;
      settings = {
        "logo" = {
          "type" = "small";
        };
        "display" = { };
        "modules" = [
          "os"
          "kernel"
          "uptime"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "battery"
        ];
      };
    };

    home.packages = with pkgs; [
      dust
      duf
      hyperfine
      tealdeer
      typos
      lazysql
    ];
  };
}
