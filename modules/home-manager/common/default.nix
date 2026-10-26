{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../.
    inputs.nix-index-database.homeModules.nix-index
  ];

  # Hosts override scalar defaults normally; package lists merge additively.
  home.username = lib.mkDefault "atalariq";
  home.packages = with pkgs; [
    just
    jq
    curl
    rsync
    sops
    age
    gnupg
    less
    eza
  ];
  xdg.enable = lib.mkDefault true;
  programs = {
    home-manager.enable = lib.mkDefault true;
    bash.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    git = {
      enable = lib.mkDefault true;
      settings.user = {
        name = lib.mkDefault "Atalariq Barra Hadinugraha";
        email = lib.mkDefault "atalariq.dev@outlook.com";
        username = lib.mkDefault "atalariq";
      };
    };
    direnv.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    nix-index = {
      enable = lib.mkDefault true;
      enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    };
    fd.enable = lib.mkDefault true;
    ripgrep.enable = lib.mkDefault true;
  };
  dotfiles.programs = {
    tmux.enable = lib.mkDefault true;
    vim.enable = lib.mkDefault true;
    bat.enable = lib.mkDefault true;
  };
}
