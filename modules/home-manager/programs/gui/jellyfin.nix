{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.jellyfin;
in
{
  options.dotfiles.programs.gui.jellyfin = {
    enable = lib.mkEnableOption "the Jellyfin desktop client";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jellyfin-desktop;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
