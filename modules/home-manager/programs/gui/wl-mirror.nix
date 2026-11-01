{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.wl-mirror;
in
{
  options.dotfiles.programs.gui.wl-mirror = {
    enable = lib.mkEnableOption "wl-mirror";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wl-mirror;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
