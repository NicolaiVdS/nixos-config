{
  lib,
  inputs,
  config,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
  homeModules = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.common = { pkgs, ... }: {
    imports = [
      nixosModules.hyprland
      nixosModules.autologin
    ];

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

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
    boot.loader.limine.maxGenerations = 5;
    boot.loader.efi.canTouchEfiVariables = true;

    # --- Plymouth: splash + password prompt for LUKS --------------------
    boot.plymouth.enable = true;
    boot.initrd.systemd.enable = true; # needed so Plymouth can show the LUKS unlock prompt
    boot.kernelParams = [
      "quiet"
      "splash"
    ];
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = true;

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

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.nicolaivds.imports = [
        homeModules.hyprland
        homeModules.autologin
        { home.stateVersion = "26.05"; }
      ];
    };
  };
}
