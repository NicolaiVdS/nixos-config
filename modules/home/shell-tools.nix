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

      btop
      curl
      wget
      rustup
      exiftool
      bun
      clang
      lazygit
      unzip
      tree-sitter
      p7zip
      unixODBC
      quickshell
    ];
  };
}
