{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.lazysql;
in
{
  options.dotfiles.programs.cli.lazysql = {
    enable = lib.mkEnableOption "lazysql";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lazysql;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
