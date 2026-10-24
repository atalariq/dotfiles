{ pkgs, inputs, ... }:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
  # Shared behaviour, no username, HOME or machine hardware belongs in a profile.
  programs = {
    bash.enable = true;
    fish.enable = true;
    atuin.enable = true;
    starship.enable = true;
    direnv.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    fzf.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
    nh.enable = true;
    nh.clean.enable = false;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
  };
  dotfiles.programs = {
    bat.enable = true;
    tmux.enable = true;
    vim.enable = true;
  };
  home.packages = with pkgs; [
    eza
    jq
    coreutils
    findutils
    gnugrep
    gnused
    diffutils
    curl
    wget
    gnutar
    unzip
    zip
    less
    delta
    dust
    hyperfine
    tealdeer
    usage
    typos
  ];
}
