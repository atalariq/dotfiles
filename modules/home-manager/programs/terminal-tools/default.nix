{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.terminal-tools.enable =
    lib.mkEnableOption "the terminal-tools package bundle";

  # Optional CLI/TUI tools that are useful but not part of the every-host core.
  config = lib.mkIf config.dotfiles.bundles.terminal-tools.enable {
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

    home.packages = with pkgs; [
      dust
      duf
      hyperfine
      tealdeer
      usage
      typos
      lazysql
    ];
  };
}
