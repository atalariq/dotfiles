{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.kdenlive;
in
{
  options.dotfiles.programs.gui.kdenlive = {
    enable = lib.mkEnableOption "kdenlive";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kdePackages.kdenlive;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
