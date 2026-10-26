{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Modules declare features; each host makes its own explicit selection.
  imports = [
    ./programs
    ./services/secrets.nix
    ./desktop
    ../stylix
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
    allowThemedFiles = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Explicitly accept immutable themed files alongside live native sources.";
    };
    checkout = lib.mkOption {
      type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
      default = "${config.home.homeDirectory}/.dotfiles";
      description = "Absolute source checkout used by live native configurations.";
    };
  };
  config = {
    assertions = [
      {
        assertion =
          config.dotfiles.deployment.mode != "live"
          || !config.dotfiles.appearance.enable
          || config.dotfiles.deployment.allowThemedFiles;
        message = "Live deployment with appearance generates immutable themed files: edits to those files require a rebuild. Set dotfiles.deployment.allowThemedFiles = true to explicitly accept this limitation.";
      }
    ];
    warnings = lib.optional (
      config.dotfiles.deployment.mode == "live"
      && config.dotfiles.appearance.enable
      && config.dotfiles.deployment.allowThemedFiles
    ) "Live deployment: themed files remain immutable and require a rebuild.";
    _module.args.dotfilesLib = import ./sources.nix {
      inherit lib config pkgs;
      checkout = config.dotfiles.deployment.checkout;
    };
  };
}
