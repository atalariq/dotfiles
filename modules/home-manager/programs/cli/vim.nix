{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.cli.vim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "vim configuration";
  };

  config = lib.mkIf (config.dotfiles.programs.cli.enable && config.dotfiles.programs.cli.vim.enable) {

    home.packages = with pkgs; [ vim ];
    home.file.".vimrc".source = dotfilesLib.sourceFor "vim" ./config/vim/vimrc;
    home.file.".vim/colors/dotfiles.vim".source = lib.mkIf (!config.dotfiles.appearance.enable) (
      dotfilesLib.sourceFor "vim" ./config/vim/colors/dotfiles.vim
    );

  };
}
