{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.slack;
in
{
  options.dotfiles.programs.gui.slack = {
    enable = lib.mkEnableOption "slack";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.slack;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
