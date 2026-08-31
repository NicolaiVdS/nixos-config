{ inputs, ... }:
{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
    };
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    security.polkit.enable = true;
  };

  flake.modules.homeManager.hyprland = { pkgs, ... }: {
    # xdg.configFile."hypr" = {
    #  source = ../dotfiles/hypr;
    #  recursive = true;
    # };
  };
}
