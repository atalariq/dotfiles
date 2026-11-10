{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.cli.fastfetch.enable = lib.mkEnableOption "fastfetch";

  config = lib.mkIf config.dotfiles.programs.cli.fastfetch.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        "logo" = {
          "type" = "small";
          "padding" = {
            "top" = 1;
            "left" = 2;
            "right" = 2;
          };
        };
        "display" = {
          "separator" = "  ";
          "key" = {
            "width" = 10;
          };
        };
        "modules" = [
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "battery"
          "break"
          "colors"
        ];
      };
    };
  };
}
