{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.tealdeer;
in
{
  options.dotfiles.programs.cli.tealdeer = {
    enable = lib.mkEnableOption "tealdeer";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tealdeer;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
