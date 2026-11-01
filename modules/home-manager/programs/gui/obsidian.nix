{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.obsidian;
in
{
  options.dotfiles.programs.gui.obsidian = {
    enable = lib.mkEnableOption "obsidian";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.obsidian;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
