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

        if [ ! -e "${config.home.homeDirectory}/.zshrc" ] ||
           [ -L "${config.home.homeDirectory}/.zshrc" ]; then
          $DRY_RUN_CMD ln -sfn \
            "${dotfilesDir}/.zshrc" \
            "${config.home.homeDirectory}/.zshrc"
        fi
      '';

      xdg.configFile = {
        "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/ghostty";
        "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/hypr";
        "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
        "ohmyposh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/ohmyposh";
        "superfile".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/superfile";
      };
    };
}
