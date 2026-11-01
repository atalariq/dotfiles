{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.scrcpy;
in
{
  options.dotfiles.programs.gui.scrcpy = {
    enable = lib.mkEnableOption "scrcpy";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.scrcpy;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
