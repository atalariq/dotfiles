# "Open in folder" from a browser goes through xdg-desktop-portal, which calls
# org.freedesktop.FileManager1.ShowItems and waits 25 seconds before falling
# back. Nautilus only acquires that bus name after a cold start, so the first
# request always times out on this host.
#
# Keep one Nautilus instance alive for the session: the name is owned before
# the browser asks, ShowItems returns immediately, and icon/font caches are
# warm. It is part of the Umbriel session, not a login-wide daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.desktop.portal;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.dotfiles.desktop.portal = {
    prewarmFileManager = lib.mkEnableOption "a warm Nautilus FileManager1 instance for the session" // {
      default = true;
    };
  };

  config = lib.mkIf (isLinux && config.dotfiles.desktop.umbriel.enable && cfg.prewarmFileManager) {
    systemd.user.services.nautilus-prewarm = {
      Unit = {
        Description = "Warm Nautilus FileManager1 for portal ShowItems";
        Documentation = [ "https://flatpak.github.io/xdg-desktop-portal/docs/" ];
        PartOf = [ "umbriel-session.target" ];
        After = [ "umbriel.service" ];
      };
      Service = {
        # --gapplication-service keeps the process in the background without
        # opening a window. Restart=always matters: if Nautilus exits when it
        # has no windows, the next browser request must not pay the cold start.
        ExecStart = "${pkgs.nautilus}/bin/nautilus --gapplication-service";
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = [ "umbriel-session.target" ];
    };
  };
}
