{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.fastfetch;
in
{
  options.dotfiles.programs.cli.fastfetch = {
    enable = lib.mkEnableOption "fastfetch";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fastfetch;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      inherit (cfg) package;
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
