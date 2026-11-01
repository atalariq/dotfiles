{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.aria2;
in
{

  options.dotfiles.programs.cli.aria2 = {
    enable = lib.mkEnableOption "aria2 configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.aria2;
    };
  };

  config = lib.mkIf config.dotfiles.programs.cli.aria2.enable {

    home.packages = [ cfg.package ];
    xdg.configFile."aria2/aria2.conf".source = dotfilesLib.source ./config/aria2/aria2.conf;

  };
}
