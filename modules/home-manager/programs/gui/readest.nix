{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.readest;
in
{
  options.dotfiles.programs.gui.readest = {
    enable = lib.mkEnableOption "readest";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.readest;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
