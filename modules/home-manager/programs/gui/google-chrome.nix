{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.google-chrome;
in
{
  options.dotfiles.programs.gui.google-chrome = {
    enable = lib.mkEnableOption "google-chrome";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.google-chrome;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
