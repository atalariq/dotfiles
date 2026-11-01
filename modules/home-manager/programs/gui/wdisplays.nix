{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.wdisplays;
in
{
  options.dotfiles.programs.gui.wdisplays = {
    enable = lib.mkEnableOption "wdisplays";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wdisplays;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
