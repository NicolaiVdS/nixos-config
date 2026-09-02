{ ... }:
{
  flake.modules.homeManager.dotfiles =
    { config, pkgs, ... }:
    let
      dotfilesDir = "${config.home.homeDirectory}/dotfiles";
      dotfilesRepo = "https://github.com/NicolaiVdS/dotfiles.git";
    in
    {
      home.activation.syncDotfiles = config.lib.dag.entryBefore [ "checkLinkTargets" ] ''
        if [ ! -d "${dotfilesDir}" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
            "${dotfilesRepo}" \
            "${dotfilesDir}"
        else
          $DRY_RUN_CMD ${pkgs.git}/bin/git -C \
            "${dotfilesDir}" pull --rebase
        fi
      '';

      home.file.".zshrc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.zshrc";
        force = true;
      };

      xdg.configFile = {
        "ghostty" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/ghostty";
          force = true;
        };
        "hypr" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/hypr";
          force = true;
        };
        "nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
          force = true;
        };
        "ohmyposh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/ohmyposh";
          force = true;
        };
        "superfile" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/superfile";
          force = true;
        };
      };
    };
}
