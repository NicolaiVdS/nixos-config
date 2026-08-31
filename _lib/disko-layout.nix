{ disk, luksName, swapSizeGiB ? null }:
{ lib, ... }:
{
  disko.devices = {
    disk.main ={
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = lib.recursiveUpdate
          (lib.optionalAttrs (swapSizeGiB != null) {
            swap = {
              size = "${toString swapSizeGiB}G";
              content = {
                type = "swap";
                resumeDevice = true;
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
                  subVolumes = {
                    "/root-blank" = { };
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
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
