{ config, checkout, ... }:
{
  imports = [
    ./packages.nix
    ./fish
    ./git
    ./neovim
    ./development
    ./typst
    ./vim
    ./yazi
    ./bat
    ./fd
    ./ripgrep
    ./fzf
    ./starship
    ./gh
    ./lazygit
    ./htop
    ./tmux
    ./rtk
    ./tirith
    ./opencode
    ./codex
    ./claude
  ];

  home.username = "atalariq";
  home.homeDirectory = "/home/atalariq";
  home.stateVersion = "26.05";
  xdg.enable = true;
  programs.home-manager.enable = true;
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.local/script"
  ];

  home.file.".config/sops/secrets.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/secrets/secrets.yaml";
  home.file.".local/script/secrets-load".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/secrets/load.sh";
}
