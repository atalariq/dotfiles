{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.bitwarden;
in
{
  options.dotfiles.programs.gui.bitwarden.enable = lib.mkEnableOption "Bitwarden user integration";

  config = lib.mkIf cfg.enable {
    # Keep bitwarden-desktop in environment.systemPackages: polkit discovers
    # its action from the system profile, and Home Manager installs have not
    # exposed it reliably. This module only owns user-level integration.
    xdg.configFile."autostart/bitwarden.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bitwarden
      Comment=Bitwarden startup script
      Exec=/run/current-system/sw/bin/bitwarden --autostart
      StartupNotify=false
      Terminal=false
    '';

    # Bitwarden's Linux manifest loop aborts at the first browser whose
    # NativeMessagingHosts directory is missing. Chromium is checked before
    # Brave; create it so the Brave manifest is written too.
    xdg.configFile."chromium/NativeMessagingHosts/.keep".text = "";

    # Persistent biometric unlock is runtime state: Bitwarden only writes the
    # BitwardenBiometricsV2 Secret Service item when the user unchecks
    # "Require master password or PIN on app restart". The polkit action and
    # fprintd PAM stack are already provided by dotfiles.security.authentication.
  };
}
