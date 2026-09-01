{ lib, ... }:
{
  flake.modules.nixos.common = { pkgs, ... }: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true; # nvidia, zen-browser, etc. need this

    time.timeZone = lib.mkDefault "Europe/Brussels";
    i18n.defaultLocale = "en_US.UTF-8";

    # --- zram (matches your Arch setup) --------------------------------
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    # --- bootloader: Limine, EFI -----------------------------------------
    boot.loader.limine.enable = true;
    boot.loader.limine.maxGenerations = 10;
    boot.loader.efi.canTouchEfiVariables = true;

    # --- Plymouth: splash + password prompt for LUKS --------------------
    boot.plymouth.enable = true;
    boot.initrd.systemd.enable = true; # needed so Plymouth can show the LUKS unlock prompt
    boot.kernelParams = [
      "quiet"
      "splash"
    ];
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;

    # --- single-user account ---------------------------------------------
    users.users.nicolaivds = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "input"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;

    networking.networkmanager.enable = true;
  };
}
