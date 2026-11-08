{
  config,
  lib,
  pkgs,
  ...
}:
let
  # pam_fprintd defaults to timeout=30, and PAM is serial: a typed password is
  # not checked until the fingerprint module gives up. Keep the fallback short
  # wherever PAM-level fingerprint auth is still wanted.
  fprintdSettings = {
    timeout = 5;
    "max-tries" = 1;
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.security.ssh-server.enable { services.openssh.enable = true; })

    (lib.mkIf config.dotfiles.security.authentication.enable {
      # Use GCR's keyring-backed SSH agent so keys persist across logins and
      # unlock with the login keyring. GnuPG stays separate for
      # signing/decryption through the graphical pinentry.
      programs.ssh.startAgent = false;
      services.gnome.gcr-ssh-agent.enable = true;
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
        pkgs.rbw
        # rbw spawns `pinentry` from PATH; the gpg-agent pinentry setting
        # alone does not expose it. This package provides pinentry,
        # pinentry-curses, pinentry-gnome3, and pinentry-tty.
        pkgs.pinentry-gnome3
      ];
      security.pam.services = {
        polkit-1 = {
          fprintAuth = true;
          rules.auth.fprintd.settings = fprintdSettings;
        };
        greetd = {
          # The greetd module uses useDefaultRules = false and writes its own
          # auth stack (substack login), so fprintAuth/unixAuth here are inert.
          # Add the fingerprint rule explicitly, ahead of the login substack.
          rules.auth.fprintd = {
            control = "sufficient";
            modulePath = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
            settings = fprintdSettings;
            order = config.security.pam.services.greetd.rules.auth.login.order - 100;
          };
        };
        login = {
          # Noctalia's lockscreen verifies fingerprints natively through
          # fprintd, so a PAM pam_fprintd rule here only delays typed passwords.
          fprintAuth = false;
          unixAuth = true;
          enableGnomeKeyring = true;
        };
        sudo = {
          fprintAuth = true;
          unixAuth = true;
          rules.auth.fprintd.settings = fprintdSettings;
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
