{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.system.impermanence;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.persistPath != "/";
        message = "dotfiles.system.impermanence.persistPath must not be the volatile root itself.";
      }
      {
        # A wiped /etc plus mutable users means the password hash is recreated
        # empty on every boot; this combination must be rejected.
        assertion = !config.users.mutableUsers;
        message = "Impermanence requires users.mutableUsers = false; declare hashedPasswordFile instead.";
      }
      {
        assertion =
          !(config.fileSystems ? ${cfg.persistPath}) || config.fileSystems.${cfg.persistPath}.neededForBoot;
        message = "The persistence filesystem must set neededForBoot = true.";
      }
    ];

    # The root subvolume is deleted and recreated in the initrd. btrfs itself
    # must be available there, together with the tools the unit calls.
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    boot.initrd.systemd.initrdBin = [ pkgs.btrfs-progs ];

    boot.initrd.systemd.services.rollback-root = {
      description = "Delete and recreate the btrfs root subvolume (impermanence)";
      wantedBy = [ "initrd.target" ];
      requires = [ "dev-disk-by\\x2dlabel-nixos.device" ];
      after = [ "dev-disk-by\\x2dlabel-nixos.device" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -o subvol=/ /dev/disk/by-label/nixos /mnt

        # Nested subvolumes must go first or the root delete fails.
        if [ -e /mnt/root ]; then
          btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read -r sv; do
            btrfs subvolume delete "/mnt/$sv"
          done
          btrfs subvolume delete /mnt/root
        fi

        btrfs subvolume create /mnt/root
        umount /mnt
      '';
    };

    # Host keys live on the persistence root so sshd has them before any bind
    # mount is in place; losing them would lock remote access out.
    services.openssh.hostKeys = [
      {
        path = "${cfg.persistPath}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    # sshd-keygen writes into a directory that must exist before the first
    # boot; tmpfiles creates it on the persistence root.
    systemd.tmpfiles.rules = [ "d ${cfg.persistPath}/etc/ssh 0755 root root -" ];

    # Baseline: what the system rewrites on its own during a normal boot.
    # /var/log is a separate subvolume on this host, so it is not bound here.
    environment.persistence.${cfg.persistPath} = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/private"
        "/var/lib/systemd"
      ]
      ++ cfg.directories;
      files = [ "/etc/machine-id" ] ++ cfg.files;
    };
  };
}
