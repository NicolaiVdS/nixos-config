{
  disk,
  luksName,
  swapSizeGiB ? null,
}:
{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions =
          lib.recursiveUpdate
            (lib.optionalAttrs (swapSizeGiB != null) {
              swap = {
                size = "${toString swapSizeGiB}G";
                content = {
                  type = "swap";
                  resumeDevice = true; # wires boot.resumeDevice for hibernation
                };
              };
            })
            {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };

              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = luksName;
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/root-blank" = { }; # unused for now -- wired up in the impermanence step
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
                      "/persist" = {
                        mountpoint = "/persist";
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
  };
}
