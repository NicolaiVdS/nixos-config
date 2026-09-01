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

    myImpermanence = {
      enable = true;
      rootDevice = "/dev/mapper/cryptroot";
      luksName = "cryptroot";
    };

    hardware.graphics.enable = true;

    system.stateVersion = "26.05";
  };
}
