{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.terminal = {
    core.enable = lib.mkEnableOption "core tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.terminal.core.enable {
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
        man-pages
        delta
        dust
        hyperfine
        tealdeer
        usage
        typos
      ];
    })
  ];
}
