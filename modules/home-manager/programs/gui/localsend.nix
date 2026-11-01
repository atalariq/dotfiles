{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.localsend;
in
{
  options.dotfiles.programs.gui.localsend = {
    enable = lib.mkEnableOption "localsend";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.localsend;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
