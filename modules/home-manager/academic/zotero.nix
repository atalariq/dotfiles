{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.academic.zotero.enable = lib.mkEnableOption "zotero";
  config = lib.mkIf config.dotfiles.academic.zotero.enable { home.packages = with pkgs; [ zotero ]; };
}
