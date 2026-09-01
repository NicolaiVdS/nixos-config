{ ... }:
{
  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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

        luksName = lib.mkOption {
          type = lib.types.str;
          description = "LUKS mapping name, e.g. cryptroot (must match disko-layout's luksName)";
        };
      };

      config = lib.mkIf cfg.enable {
        boot.initrd.systemd.services.rollback-root = {
          description = "Roll back root btrfs subvolume to blank state";
          wantedBy = [ "initrd.target" ];
          after = [ "systemd-cryptsetup@${cfg.luksName}.service" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          path = [ pkgs.btrfs-progs ];
          script = ''
            mkdir -p /mnt
            mount -o subvol=/ ${cfg.rootDevice} /mnt

            if [ -e /mnt/root ]; then
              btrfs subvolume delete /mnt/root
            fi

            btrfs subvolume snapshot /mnt/root-blank /mnt/root

            umount /mnt
          '';
        };

        fileSystems."/persist".neededForBoot = true;

        environment.persistence."/persist" = {
          hideMounts = true;

          directories = [
            "/etc/NetworkManager/system-connections"
            "/var/lib/bluetooth"
            "/var/log"
            "/var/lib/nixos"
          ];

          files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
          ];
        };
      };
    };
}
