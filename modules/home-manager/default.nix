# Shared Home Manager profile for the public dotfiles.
#
# This module is deliberately platform-neutral: the standalone
# `homeConfigurations` and the generic NixOS/Darwin examples all import it.
# Hosts that need server or desktop configuration add their own modules.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.identity;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  imports = [
    ./programs
    ../stylix
  ];

  options.dotfiles.identity = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "atalariq";
      description = "Login name and the name Home Manager manages.";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Atalariq Barra Hadinugraha";
      description = "Git author name; change it if this is not your machine.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "atalariq.dev@outlook.com";
      description = "Git author email.";
    };
    device = lib.mkOption {
      type = lib.types.str;
      default = "heighliner";
      description = "Label shown in the prompt and MOTD; not the OS hostname.";
    };
  };

  options.dotfiles.deployment = {
    mode = lib.mkOption {
      type = lib.types.enum [
        "immutable"
        "live"
      ];
      default = "immutable";
      description = ''
        "immutable" points native configuration at the store copy; "live" links
        it to the checkout so edits apply without a rebuild.
      '';
    };
    allowThemedFiles = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Explicitly accept immutable themed files alongside live native sources.";
    };
    checkout = lib.mkOption {
      type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
      default = "${config.home.homeDirectory}/Repos/dotfiles";
      description = "Absolute public framework checkout used by live native configurations.";
    };
    inventory = lib.mkOption {
      type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
      default = "${config.home.homeDirectory}/.dotfiles";
      description = "Absolute private inventory checkout used by inventory-owned live configuration.";
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = if isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
    home.stateVersion = lib.mkDefault "26.05";
    home.sessionVariables = {
      DOTFILES_HOST = cfg.device;
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    xdg.enable = lib.mkDefault true;
    programs.home-manager.enable = lib.mkDefault true;
    stylix.autoEnable = lib.mkDefault false;

    assertions = [
      {
        assertion =
          config.dotfiles.deployment.mode != "live"
          || (lib.all
            (
              path:
              lib.hasPrefix (config.home.homeDirectory + "/") path
              && !lib.hasInfix "/../" path
              && !lib.hasInfix "/./" path
            )
            [
              config.dotfiles.deployment.checkout
              config.dotfiles.deployment.inventory
            ]
          );
        message = "dotfiles.deployment.checkout and inventory must stay inside the home directory without '.' or '..' segments.";
      }
    ];
  };
}
