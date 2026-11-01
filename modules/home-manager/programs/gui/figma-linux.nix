{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.figma-linux;
in
{
  options.dotfiles.programs.gui.figma-linux = {
    enable = lib.mkEnableOption "figma-linux";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.figma-linux;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
