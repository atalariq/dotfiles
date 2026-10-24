{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.development.git.enable = lib.mkEnableOption "git configuration";

  config = lib.mkIf config.dotfiles.development.git.enable {

    home.packages = with pkgs; [
      git
      git-lfs
      difftastic
    ];
    home.file.".gitconfig".source = dotfilesLib.source ./config/gitconfig;
    home.file.".gitignore_global".source = dotfilesLib.source ./config/gitignore_global;

  };
}
