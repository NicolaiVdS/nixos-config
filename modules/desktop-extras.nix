{ ... }:
{
  flake.modules.nixos.desktop-extras = { pkgs, ... }: {
    programs.steam.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      gsettings-desktop-schemas
      hyprpolkitagent
    ];
  };
}
