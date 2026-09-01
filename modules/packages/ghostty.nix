{ ... }:
{
  flake.modules.homeManager.ghostty = { pkgs, ... }: {
    home.pkgs = [ pkgs.ghostty ];
  };
}
