{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.nautilus;
in
{
  options.dotfiles.programs.gui.nautilus = {
    enable = lib.mkEnableOption "nautilus";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nautilus;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
