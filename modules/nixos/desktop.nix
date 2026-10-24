{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The greeter starts a Bash login environment before the compositor, so HM's
  # session variables also reach Fish terminals and graphical applications.
  session = pkgs.writeShellScript "mango-login" ''
    exec ${pkgs.bash}/bin/bash --login -c ${lib.escapeShellArg "exec ${config.programs.mango.package}/bin/mango"}
  '';
in
{
  # Mango preserves the existing tiling/keybinding workflow. Noctalia owns the
  # shell and lock screen; see docs/decisions.md.
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.desktop.mango.enable {
      programs.mango.enable = true;
      # Upstream marks graphical-desktop enabled, which would otherwise default
      # PipeWire on. Preserve our explicit audio selection at normal priority.
      services.pipewire.enable = config.dotfiles.desktop.audio.enable;
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${session}";
          user = "greeter";
        };
      };
      # A rebuild must not terminate the graphical session.
      systemd.services.greetd.restartIfChanged = false;
      services.displayManager.defaultSession = "mango";
      security.polkit.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
      services.libinput.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.audio.enable {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    })
    (lib.mkIf config.dotfiles.desktop.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.files.enable {
      services.udisks2.enable = true;
      services.gvfs.enable = true;
    })
    (lib.mkIf config.dotfiles.desktop.espanso.enable {
      services.espanso = {
        enable = true;
        package = pkgs.espanso-wayland;
        extraPackages = [
          pkgs.bash
          pkgs.curl
        ];
      };
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
