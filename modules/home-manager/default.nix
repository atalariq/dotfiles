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
    ./services/syncthing.nix
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
    liveApps = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "espanso"
          "vim"
          "neovim"
          "hermes"
          "opencode"
          "fish"
          "ghostty"
          "kitty"
          "tmux"
          "television"
          "umbriel"
          "noctalia"
        ]
      );
      default = [ ];
      description = "Applications whose supported native files link to the checkout; generated settings still rebuild.";
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
    home.username = lib.mkDefault "atalariq";
    xdg.enable = lib.mkDefault true;
    programs.home-manager.enable = lib.mkDefault true;
    # Stylix auto-enables its per-target modules (and defines
    # `nixpkgs.overlays`) unless a host selects appearance. NixOS hosts run
    # Home Manager with useGlobalPkgs, which rejects those overlay
    # definitions, so the catalogue stays inert until appearance is selected.
    stylix.autoEnable = lib.mkDefault false;
    assertions = [
      {
        assertion =
          config.dotfiles.deployment.mode != "live"
          || !config.dotfiles.appearance.enable
          || config.dotfiles.deployment.allowThemedFiles;
        message = "Live deployment with appearance generates immutable themed files: edits to those files require a rebuild. Set dotfiles.deployment.allowThemedFiles = true to explicitly accept this limitation.";
      }
    ];
    warnings =
      lib.optional (
        config.dotfiles.deployment.mode == "live"
        && config.dotfiles.appearance.enable
        && config.dotfiles.deployment.allowThemedFiles
      ) "Live deployment: themed files remain immutable and require a rebuild."
      ++
        lib.optional
          (lib.any (app: builtins.elem app config.dotfiles.deployment.liveApps) [
            "hermes"
            "opencode"
          ])
          "Hermes/OpenCode native profiles remain writable; legacy liveApps entries do not synchronize runtime profiles. Use native config edits or project configuration for runtime changes.";
    _module.args.dotfilesLib = import ./sources.nix {
      inherit lib config pkgs;
      checkout = config.dotfiles.deployment.checkout;
    };
  };
}
