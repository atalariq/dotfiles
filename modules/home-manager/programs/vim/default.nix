{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.vim.enable = lib.mkEnableOption "vim configuration";

  config = lib.mkIf config.dotfiles.programs.vim.enable {

    home.packages = with pkgs; [ vim ];
    home.file.".vimrc".source = dotfilesLib.sourceFor "vim" ./config/vimrc;
    home.file.".vim/colors/dotfiles.vim".source = lib.mkIf (!config.dotfiles.appearance.enable) (
      dotfilesLib.sourceFor "vim" ./config/colors/dotfiles.vim
    );

  };
}
