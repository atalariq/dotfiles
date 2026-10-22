{ pkgs, ... }:
{
  home.packages = with pkgs; [
    age
    sops
    eza
    zoxide
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
    man-pages
    delta
    dust
    hyperfine
    tealdeer
    usage
    typos
  ];
}
