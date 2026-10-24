{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fastfetch.settings = lib.mkIf config.programs.fastfetch.enable {
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
}
