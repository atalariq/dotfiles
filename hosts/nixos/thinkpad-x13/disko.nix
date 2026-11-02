# Target layout for a future fresh install of the ThinkPad.
#
# This file is NOT imported by the running host: the current system still uses
# UUID-based fileSystems from hardware-configuration.nix. It exists so a
# reinstall can describe the disk with stable names (mapper names and by-id
# device) instead of generating new UUIDs every time.
#
# Current disk: WDC PC SN730 512G, ESP 1G + LUKS root + LUKS swap.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WDC_PC_SN730_SDBQNTY-512G-1001_222308444908";
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
        swap = {
          size = "8800M";
          content = {
            type = "luks";
            name = "cryptswap";
            content.type = "swap";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
