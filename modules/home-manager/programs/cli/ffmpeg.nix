{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.ffmpeg;
in
{
  options.dotfiles.programs.cli.ffmpeg = {
    enable = lib.mkEnableOption "ffmpeg";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ffmpeg;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
