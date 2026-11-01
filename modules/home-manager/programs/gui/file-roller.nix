{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.file-roller;
in
{
  options.dotfiles.programs.gui.file-roller = {
    enable = lib.mkEnableOption "file-roller";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.file-roller;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
