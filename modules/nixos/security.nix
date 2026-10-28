{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.security.ssh-server.enable { services.openssh.enable = true; })

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
      security.polkit.enable = true;
      # Polkit reads system policy paths, not the Home Manager profile.
      environment.systemPackages = [
        pkgs.bitwarden-desktop
        pkgs.bitwarden-cli
      ];
      security.pam.services = {
        polkit-1.fprintAuth = true;
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
    (lib.mkIf config.dotfiles.security.tpm.enable {
      security.tpm2.enable = true;
      security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
      # The consuming host adds its user to the "tss" group, which owns the TPM
      # device nodes; support alone must not grant access.
    })
  ];
}
