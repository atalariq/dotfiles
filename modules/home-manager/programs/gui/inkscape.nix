{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.inkscape;
in
{
  options.dotfiles.programs.gui.inkscape = {
    enable = lib.mkEnableOption "inkscape";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.inkscape;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
