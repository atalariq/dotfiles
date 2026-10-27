{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Shell/POSIX basics, archive tools and the MIME/icon plumbing that desktop
  # applications expect from a base system.
  config = lib.mkIf config.dotfiles.bundles.core.enable {
    home.packages = with pkgs; [
      coreutils
      findutils
      gnugrep
      gnused
      diffutils
      wget
      gnutar
      unzip
      zip
      psmisc
      xdg-utils
      libsecret
      adwaita-icon-theme
    ];
  };
}
