{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.hyperfine;
in
{
  options.dotfiles.programs.cli.hyperfine = {
    enable = lib.mkEnableOption "hyperfine";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hyperfine;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
