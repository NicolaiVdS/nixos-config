{ ... }:
{
  flake.modules.nixos.autologin = { ... }: {
    services.getty.autologinUser = "nicolaivds";

    # Launch Hyprland automatically when logging into tty1
    environment.loginShellInit = ''
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        echo -n "Starting Hyperland in 1s... (press ANY key to cancel)"
        if read -t 1 -k 1 -s key; then
          echo -e "\nBypassed Hyprland, Dropping into tty."
        else
          echo -e "\nLaunching Hyprland..."
          exec start-hyprland
        fi
      fi
    '';
  };

  flake.modules.homeManager.autologin = { ... }: { };
}
