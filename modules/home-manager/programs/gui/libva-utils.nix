{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.libva-utils;
in
{
  options.dotfiles.programs.gui.libva-utils = {
    enable = lib.mkEnableOption "libva-utils";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.libva-utils;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
