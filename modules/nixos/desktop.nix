{
  config,
  lib,
  pkgs,
  ...
}:
let
  style = import ../stylix/style.nix { inherit pkgs; };
  c = lib.mapAttrs (_: value: "#${value}") (
    builtins.removeAttrs style.base16Scheme [
      "scheme"
      "author"
    ]
  );
in
{
  # The session package and the login greeter are independent selections:
  # enabling Umbriel does not make it the greeter's default session, so the
  # host sets both explicitly.
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.desktop.umbriel.enable {
      programs.umbriel.enable = true;
      # The pinned wrapper expects Xwayland on PATH; supply it explicitly.
      environment.systemPackages = [ pkgs.xwayland ];
      services.pipewire.enable = config.dotfiles.desktop.audio.enable;
      services.libinput.enable = true;
      # Noctalia's polkit agent needs the daemon running system-wide.
      security.polkit.enable = true;
      xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    })
    (lib.mkIf config.dotfiles.desktop.greeter.enable {
      services.displayManager.noctalia-greeter = {
        enable = true;
        cursorTheme = {
          package = style.cursor.package;
          name = style.cursor.name;
        };
        settings = {
          cursor.size = style.cursor.size;
          keyboard.layout = "us";
          # Empty submission starts the existing fingerprint PAM conversation.
          auth.allow_empty_password = true;
          appearance = {
            scheme = "Synced";
            theme_mode = style.polarity;
            font_family = style.fonts.sansSerif.name;
            palette = {
              primary = c.base0B;
              on_primary = c.base00;
              secondary = c.base0D;
              on_secondary = c.base00;
              tertiary = c.base0E;
              on_tertiary = c.base00;
              error = c.base08;
              on_error = c.base00;
              surface = c.base00;
              on_surface = c.base05;
              surface_variant = c.base01;
              on_surface_variant = c.base04;
              outline = c.base03;
              shadow = c.base00;
              hover = c.base02;
              on_hover = c.base05;
            };
          };
        };
      };
      services.greetd.useTextGreeter = false;
      # Defer the new greeter to logout/reboot, preserving the current session.
      systemd.services.greetd.restartIfChanged = false;
    })
    (lib.mkIf config.dotfiles.desktop.audio.enable {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        # libpipewire-module-x11-bell dereferences a dead Xwayland display
        # after a lazy restart and crashes the whole daemon. That leaves
        # xdg-desktop-portal holding a dead PipeWire connection, which breaks
        # OBS screen capture until the portal is restarted.
        extraConfig.pipewire."99-disable-x11-bell" = {
          "context.properties"."module.x11.bell" = false;
        };
      };
      # Keep portal sessions consistent if PipeWire is restarted for any
      # other reason.
      systemd.user.services.xdg-desktop-portal = {
        overrideStrategy = "asDropinIfExists";
        partOf = [ "pipewire.service" ];
        after = [ "pipewire.service" ];
      };
    })
    (lib.mkIf config.dotfiles.desktop.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.printing.enable {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      services.printing = {
        enable = true;
        # cups-browsed is a service, not a driver: listing it in drivers only
        # put the binary on the system closure.
        browsed.enable = true;
        drivers = with pkgs; [
          cups-filters
          gutenprint
        ];
      };
      services.ipp-usb.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.files.enable {
      services.udisks2.enable = true;
      services.gvfs.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.espanso.enable {
      services.espanso = {
        enable = true;
        package = pkgs.espanso-wayland;
      };
      systemd.user.services.espanso.path = [
        pkgs.bash
        pkgs.curl
      ];
    })
    (lib.mkIf config.dotfiles.desktop.fonts.enable {
      fonts.packages = with pkgs; [
        dejavu_fonts
        corefonts
        eb-garamond
        newcomputermodern
        fira-code
        inter
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
      ];
    })
    (lib.mkIf config.dotfiles.desktop.noctalia.enable {
      programs.noctalia = {
        enable = true;
        # Hardware/audio/power features are selected individually by the host.
        recommendedServices.enable = false;
      };
    })
  ];
}
