{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.gh;
in
{

  options.dotfiles.programs.cli.gh = {
    enable = lib.mkEnableOption "gh configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gh;
    };
  };

  config = lib.mkIf config.dotfiles.programs.cli.gh.enable {

    home.packages = [ cfg.package ];
    # gh stores login state beside config.yml; keep that state outside the checkout.
    xdg.configFile."gh/config.yml".source = dotfilesLib.source ./config/gh/config.yml;

  };
}
