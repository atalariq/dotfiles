{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.audacity;
in
{
  options.dotfiles.programs.gui.audacity = {
    enable = lib.mkEnableOption "audacity";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.audacity;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
