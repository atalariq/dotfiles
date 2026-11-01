{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.anki;
in
{
  options.dotfiles.programs.gui.anki = {
    enable = lib.mkEnableOption "anki";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.anki;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
