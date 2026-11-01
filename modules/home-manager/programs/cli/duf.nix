{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.duf;
in
{
  options.dotfiles.programs.cli.duf = {
    enable = lib.mkEnableOption "duf";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.duf;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
