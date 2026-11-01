{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.gimp;
in
{
  options.dotfiles.programs.gui.gimp = {
    enable = lib.mkEnableOption "gimp";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gimp;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
