{ ... }:
{
  flake.nixosModules.autologin = { ... }: {
    services.getty.autologinUser = "nicolaivds";
  };

  flake.homeManagerModules.autologin = { ... }: {
    programs.zsh.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
