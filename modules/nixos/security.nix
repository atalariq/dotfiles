{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.security.authentication.enable {
      # Keep OpenSSH and GnuPG separate: forwarding keeps its inherited socket,
      # while GPG handles signing/decryption through the graphical pinentry.
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
    })
    (lib.mkIf config.dotfiles.security.secrets.enable {
      # Declarations belong to the consuming service; enabling support alone
      # neither decrypts every key nor changes the current user's password.
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    })
  ];
}
