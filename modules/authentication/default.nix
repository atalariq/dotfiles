{ pkgs, ... }:
{
  programs.ssh.startAgent = true;
  services.gnome.gcr-ssh-agent.enable = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.gnome.gnome-keyring.enable = true;
  services.fprintd.enable = true;
  security.pam.services = {
    greetd = {
      fprintAuth = true;
      unixAuth = true;
      enableGnomeKeyring = true;
    };
    # Noctalia uses login PAM for passwords and fprintd D-Bus for fingerprints.
    login = {
      fprintAuth = true;
      unixAuth = true;
      enableGnomeKeyring = true;
    };
    sudo = {
      fprintAuth = true;
      unixAuth = true;
    };
  };
}
