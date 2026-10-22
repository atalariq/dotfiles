{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [ vim ];
  home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/vim/config/vimrc";
  home.file.".vim/colors/dotfiles.vim".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/vim/config/colors/dotfiles.vim";
}
