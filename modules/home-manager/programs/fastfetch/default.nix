{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.fastfetch.enable = lib.mkEnableOption "fastfetch configuration";

  config = lib.mkIf config.dotfiles.programs.fastfetch.enable {
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
  };
}
