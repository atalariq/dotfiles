{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.blender;
in
{
  options.dotfiles.programs.gui.blender = {
    enable = lib.mkEnableOption "blender";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.blender;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
