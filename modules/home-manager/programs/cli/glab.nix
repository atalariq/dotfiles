{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.glab;
in
{
  options.dotfiles.programs.cli.glab = {
    enable = lib.mkEnableOption "glab configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.glab;
    };
  };

  config = lib.mkIf config.dotfiles.programs.cli.glab.enable {
    # Authentication and runtime state stay writable; install the binary only.
    home.packages = [ cfg.package ];
  };
}
