{ ... }:
{
  flake.modules.homeManager.superfile = { pkgs, ... }: {
    home.packages = [ pkgs.superfile ];
  };
}
