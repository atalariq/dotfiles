{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.nicotine-plus;
in
{
  options.dotfiles.programs.gui.nicotine-plus = {
    enable = lib.mkEnableOption "nicotine-plus";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nicotine-plus;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
