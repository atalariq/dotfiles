{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.dust;
in
{
  options.dotfiles.programs.cli.dust = {
    enable = lib.mkEnableOption "dust";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.dust;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
