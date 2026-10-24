{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.editors.vim.enable = lib.mkEnableOption "vim configuration";

  config = lib.mkIf config.dotfiles.editors.vim.enable {

    home.packages = with pkgs; [ vim ];
    home.file.".vimrc".source = dotfilesLib.source ./config/vimrc;
    home.file.".vim/colors/dotfiles.vim".source = lib.mkIf (
      !config.dotfiles.desktop.appearance.enable
    ) (dotfilesLib.source ./config/colors/dotfiles.vim);

  };
}
