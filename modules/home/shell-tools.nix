{ ... }:
{
  flake.modules.homeManager.shell-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      neovim
      fzf
      zoxide
      oh-my-posh
      lsd
      ripgrep
      fd
    ];
  };
}
