{ lib, pkgs, ... }:
let
  apps = import ./apps.nix { inherit pkgs; };
in
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    username = "praktikan";
    packages = apps.cli;
    sessionVariables = {
      DOTFILES_HOST = "macmini-lab";
      TERMINAL = "kitty";
    };
    homeDirectory = "/Users/praktikan";
    stateVersion = "26.05";
  };
  programs = {
    zsh.enable = true;
    # Homebrew owns the kitty binary; Home Manager still writes kitty.conf.
    kitty.package = lib.mkForce null;
  };
  dotfiles = {
    deployment.liveApps = [
      "vim"
      "neovim"
      "fish"
      "tmux"
      "television"
    ];
    programs = {
      # Java/Kotlin are handled by Android Studio; nvf only needs Node/Python.
      development = {
        stacks = apps.stacks;
        mise.enable = true;
      };
      cli = {
        enable = true;
        btop.enable = true;
        fastfetch.enable = true;
        neovim.enable = true;
        television.enable = true;
        typst.enable = true;
        yazi.enable = true;
      };
      gui.kitty.enable = true;
    };
    appearance = {
      enable = true;
      gui = true;
    };
  };
}
