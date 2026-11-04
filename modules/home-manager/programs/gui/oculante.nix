{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.oculante;
in
{
  options.dotfiles.programs.gui.oculante = {
    enable = lib.mkEnableOption "oculante image viewer";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.oculante;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
