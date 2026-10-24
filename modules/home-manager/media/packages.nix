{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.media = {
    ncmpcpp.enable = lib.mkEnableOption "ncmpcpp tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.media.ncmpcpp.enable { home.packages = with pkgs; [ ncmpcpp ]; })
  ];
}
