{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.discord;
in
{
  options.dotfiles.programs.gui.discord = {
    enable = lib.mkEnableOption "discord";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.discord;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
