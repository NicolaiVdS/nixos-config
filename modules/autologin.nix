{ ... }:
{
  flake.modules.nixos.autologin = { ... }: {
    services.getty.autologinUser = "nicolaivds";

    # Launch Hyprland automatically when logging into tty1
    environment.loginShellInit = ''
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland
      fi
    '';
  };

  flake.modules.homeManager.autologin = { ... }: {
    programs.zsh.enable = true;
  };
}
