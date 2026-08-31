{ lib, ... }:
{
  flake.modules.nixos.common = { pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    time.timeZone = lib.mkDefault "Europe/Brussels";
    i18n.defaultLocale = "en_US.UTF-8";

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    boot.loader.limine.enable = true;
    boot.loader.limine.maxGenerations = 5;
    boot.loader.efi.canTouchEfiVariables = true;
    
    boot.plymouth.emable = true;
    boot.initrd.systemd.enable = true;
    boot.kernelParams = [ "quiet" "splash" ];
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;

    users.users.nicolaivds = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "input" "networkmanager" ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;

    networking.networkmanager.enable = true;
  };
}
