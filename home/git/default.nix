{
  config,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = with pkgs; [
    git
    git-lfs
    difftastic
  ];
  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/git/config/gitconfig";
  home.file.".gitignore_global".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/git/config/gitignore_global";
}
