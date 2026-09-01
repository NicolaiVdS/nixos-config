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
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
      ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    nixpkgs.config.allowUnfree = true;

    time.timeZone = lib.mkDefault "Europe/Brussels";
    i18n.defaultLocale = "en_US.UTF-8";

    # --- zram ----------------------------------
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
    boot.initrd.systemd.enable = true;
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

    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        nswitch() {
          local repo_dir="$HOME/nixos-config"
          local repo_url="https://github.com/NicolaiVdS/nixos-config.git"
          local target_host="''${1:-$(hostname)}"

          if [ ! -d "$repo_dir" ]; then
            echo "==> Repository not found. Cloning to $repo_dir..."
            git clone "$repo_url" "$repo_dir" || return 1
          fi

          cd "$repo_dir" || return 1
          echo "==> Pulling latest changes..."
          git pull || return 1

          echo "==> Rebuilding system for host: .#$target_host..."
          sudo nixos-rebuild switch --flake ".#$target_host"
        }

        npush() {
          local repo_dir="$HOME/nixos-config"
          if [ ! -d "$repo_dir" ]; then
            echo "==> Repository directory $repo_dir does not exist."
            return 1
          fi

          cd "$repo_dir" || return 1
          git add .
          git commit -m "''${1:-sync: update nixos config}"
          git push
        }
      '';
    };

    networking.networkmanager.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.nicolaivds.imports = (builtins.attrValues homeModules) ++ [
        {
          home.username = "nicolaivds";
          home.homeDirectory = "/home/nicolaivds";
          home.stateVersion = "26.05";
        }
      ];
    };
  };
}
