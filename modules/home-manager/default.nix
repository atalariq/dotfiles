{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Catalogue imports declare features; profiles own the actual selection.
  imports = [
    ./programs
    ./services/secrets.nix
    ./desktop
    ./appearance
  ];
  options.dotfiles.deployment = {
    mode = lib.mkOption {
      type = lib.types.enum [
        "immutable"
        "live"
      ];
      default = "immutable";
      description = "Whether remaining native sources follow a generation or the checkout.";
    };
    checkout = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.dotfiles";
      description = "Absolute source checkout used by live native configurations.";
    };
  };
  config._module.args.dotfilesLib = import ../../lib/configuration.nix {
    inherit lib config pkgs;
    checkout = config.dotfiles.deployment.checkout;
  };
}
