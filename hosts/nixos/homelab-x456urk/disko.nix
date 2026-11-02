# Declarative layout for the fresh ASUS X456URK install.
#
# The SSD is wiped: Arch, Windows and their LVM/LUKS volumes are replaced.
# The media HDD is wiped too; the owner verified the backup before install.
# `/data` stays XFS: a single large-file media library does not need btrfs
# checksums or compression, and XFS keeps the layout simple.
{
  lib,
  ...
}:
let
  includeDataDisk = true;
  btrfsOpts = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk = {
    system = {
      type = "disk";
      # Stable by-id path: /dev/sda can swap names between boots.
      device = "/dev/disk/by-id/ata-V-GEN04SM24HUI128GBSDK_RLA00000000000010281";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              # The label is what the impermanence rollback unit mounts.
              extraArgs = [
                "-f"
                "-L"
                "nixos"
              ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = btrfsOpts;
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOpts;
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = btrfsOpts;
                };
                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = btrfsOpts;
                };
              };
            };
          };
        };
      };
    };
  }
  // lib.optionalAttrs includeDataDisk {
    data = {
      type = "disk";
      device = "/dev/disk/by-id/ata-HGST_HTS541010A9E680_JD1008DM2BNHTV";
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            extraArgs = [
              "-f"
              "-L"
              "data"
            ];
            mountpoint = "/data";
            mountOptions = [
              "noatime"
              # An old single disk must never block an unattended boot.
              "nofail"
            ];
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
