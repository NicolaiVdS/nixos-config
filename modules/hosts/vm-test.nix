{ config, ... }:
{
  flake.modules.hosts.vm-test = { lib, ... }: {
    imports = [
      config.flake.modules.nixos.common
      config.flake.modules.nixos.impermanence
      (import ../_lib/disko-layout.nix {
        disk = "/dev/vda";
        luksName = "cryptroot";
        swapSizeGiB = null;
      })
    ];

    # Hardware & VM specific drivers
    boot.initrd.availableKernelModules = [
      "virtio_gpu"
      "qxl"
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
    ];

    hardware.graphics.enable = true;
    myImpermanence.enable = false;

    system.stateVersion = "26.05";
  };
}
