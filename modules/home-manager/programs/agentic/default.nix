# The `dotfiles.programs.agentic` group kernel: installs the core toolset
# directly and imports every client/helper module from this directory.
#
# The core tools below are the floor for any host running agents and are atomic
# by design; extract one into its own module only if it ever needs a separate
# switch. Client subscriptions and credential-bearing tools stay individual
# opt-ins. README.md beside this file documents the namespace.
{
  config,
  inputs,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.agentic;
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  imports = [
    ./_seed.nix
  ]
  ++ (import ../_import-category.nix {
    inherit lib;
    dir = ./.;
  });

  options.dotfiles.programs.agentic = {
    core.enable = lib.mkEnableOption "the agentic core toolset (crit, rtk, tirith, Beads Rust/Viewer, CodeGraph, Tokscale)";
    experimental.enable = lib.mkEnableOption "the experimental AI toolset for evaluation";
    beads-directory = lib.mkOption {
      type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
      default = "${config.dotfiles.deployment.checkout}/.beads";
      description = "Shared dotfiles task directory; other projects retain native br discovery.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.core.enable {
      home.packages = [
        agentPackages.beads-rust
        agentPackages.beads-viewer
        agentPackages.codegraph
        agentPackages.crit
        agentPackages.rtk
        agentPackages.tokscale
        pkgs.tirith
      ];

      home.sessionVariables = {
        CRIT_NO_UPDATE_CHECK = "1";
        # Do not set BEADS_DIR globally: that would redirect unrelated projects.
        DOTFILES_BEADS_DIR = cfg.beads-directory;
      };

      xdg.configFile = {
        # crit authentication and review state remain writable; seed only absent.
        "dotfiles/templates/crit.json".text = builtins.toJSON { share_targets = [ ]; };
        # RTK owns writable state; Linux gets the whole settings dir, while
        "rtk" = lib.mkIf isLinux {
          source = dotfilesLib.source ./config/rtk;
        };
        "tirith/gateway.yaml".source = dotfilesLib.source ./config/tirith/gateway.yaml;
      };

      home.file = {
        ".tirith/policy.yaml".source = dotfilesLib.source ./config/tirith/policy.yaml;
        # RTK uses the native macOS directory for both config and writable
        # tracking. Link individual settings, leaving its database and recall
        # files writable.
        "Library/Application Support/rtk/config.toml" = lib.mkIf isDarwin {
          source = dotfilesLib.source ./config/rtk/config.toml;
        };
        "Library/Application Support/rtk/filters.toml" = lib.mkIf isDarwin {
          source = dotfilesLib.source ./config/rtk/filters.toml;
        };
      };
    })
    (lib.mkIf cfg.experimental.enable {
      # Deliberately small: only tools that are still on trial. Everything else
      # is either core or has its own opt-in module.
      home.packages = [
        agentPackages.luvus
        agentPackages.openresearch
        agentPackages.tuicr
      ];
    })
  ];
}
