{ config, lib, ... }:
let
  cfg = config.myImpermanence;
in
{
  options.myImpermanence = {
    enable = lib.mkEnableOption "impermanent root (rolled back to blank on every boot)";

    rootDevice = lib.mkOption {
      type = lib.types.str;
      description = "Mapped LUKS device for the btrfs pool, e.g. /dev/mapper/cryptroot";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir -p /mnt
      mount -o subvol=/ ${cfg.rootDevice} /mnt

      if [ -e /mnt/root ]; then
        btrfs subvolume delete /mnt/root
      fi

      btrfs subvolume snapshot /mnt/root-blank /mnt/root

      umount /mnt
    '';

    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/log"
        "/var/lib/nixos" # uid/gid maps stay stable across reboots
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };
}
