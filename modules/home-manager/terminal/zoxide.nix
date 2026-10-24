{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.terminal = {
    zoxide.enable = lib.mkEnableOption "zoxide tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.terminal.zoxide.enable { home.packages = with pkgs; [ zoxide ]; })
  ];
}
