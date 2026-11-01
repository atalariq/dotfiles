{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.typos;
in
{
  options.dotfiles.programs.cli.typos = {
    enable = lib.mkEnableOption "typos";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.typos;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
