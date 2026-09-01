{ ... }:
{
  flake.modules.nixos.autologin = { ... }: {
    services.getty.autologinUser = "nicolaivds";
  };

  flake.modules.homeManager.autologin = { ... }: {
    programs.zsh.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
