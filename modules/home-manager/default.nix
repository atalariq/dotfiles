{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./terminal
    ./editors
    ./development
    ./desktop
    ./agents
    ./downloader
    ./working
    ./academic
    ./media
    ./security
    ./gaming
  ];
  options.dotfiles.deployment = {
    mode = lib.mkOption {
      type = lib.types.enum [
        "immutable"
        "live"
      ];
      default = "immutable";
      description = "Whether native files follow generations or a live checkout.";
    };
    checkout = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.dotfiles";
      description = "Absolute source checkout for live mode and optional source-editing helpers.";
    };
  };
  config._module.args.dotfilesLib = import ../../lib/configuration.nix {
    inherit lib config pkgs;
    checkout = config.dotfiles.deployment.checkout;
  };
}
