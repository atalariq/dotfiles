{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.desktop.umbriel;
  format = pkgs.formats.toml { };
  # The scrolling axis is a module-wide default, not host boilerplate: every
  # declared output inherits it unless the host overrides that output.
  settings =
    cfg.settings
    // lib.optionalAttrs (cfg.settings ? output) {
      output = lib.mapAttrs (
        _: output: { workspace_axis = cfg.workspaceAxis; } // output
      ) cfg.settings.output;
    };
  # Umbriel expands includes first and applies this generated host/theme body
  # last. Only native behavior is live; feature/output/theme changes rebuild.
  root = entry: settings // { include.files = [ entry ]; };
  generated = format.generate "umbriel-config.toml" (
    root "${config.xdg.configHome}/umbriel/native/config.toml"
  );
  validated = pkgs.runCommand "umbriel-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out/native"
    cp -R ${./config}/. "$out/native/"
    cp ${format.generate "umbriel-validation.toml" (root "native/config.toml")} "$out/config.toml"
    ${config.programs.umbriel.package}/bin/umbriel config validate -c "$out/config.toml"
  '';
in
{
  # The flake module supplies programs.umbriel and its package; the NixOS
  # module of the same flake installs the session and the portal.
  imports = [ inputs.umbriel.homeModules.default ];

  options.dotfiles.desktop.umbriel = {
    enable = lib.mkEnableOption "Umbriel scrolling desktop";
    workspaceAxis = lib.mkOption {
      type = lib.types.enum [
        "horizontal"
        "vertical"
      ];
      default = "vertical";
      description = "Scrolling axis applied to every output unless the host overrides it.";
    };
    settings = lib.mkOption {
      inherit (format) type;
      default = { };
      description = "Generated Umbriel host/feature/theme overrides, applied after native TOML includes.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.desktop.noctalia.enable;
        message = "Umbriel requires Linux and Noctalia.";
      }
    ];
    programs.umbriel.enable = true;
    # The packaged session expects Xwayland on PATH; the flake module owns the
    # compositor and portal packages.
    home.packages = [ pkgs.xwayland ];
    home.extraDependencies = [ validated ];
    xdg.configFile = {
      "umbriel/config.toml".source = generated;
      # Link the pure native tree as one directory; runtime state stays outside.
      "umbriel/native".source = dotfilesLib.sourceFor "umbriel" ./config;
      "xdg-desktop-portal/umbriel-portals.conf".text = ''
        [preferred]
        default=umbriel;gtk
        org.freedesktop.impl.portal.Secret=gnome-keyring
        org.freedesktop.impl.portal.ScreenCast=umbriel
        org.freedesktop.impl.portal.Screenshot=umbriel
        org.freedesktop.impl.portal.FileChooser=termfilechooser
      '';
    };
    # The flake module leaves settings null so the packaged config is used; the
    # generated body above still owns autostart and host outputs.
    dotfiles.desktop.umbriel.settings = {
      # OBS autostart is owned by programs/gui/obs-studio.nix so it stays
      # independent of the compositor.
      general.autostart = [
        "systemctl --user start noctalia.service"
      ];
    };
  };
}
