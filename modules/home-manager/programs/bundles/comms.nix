{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Chat and collaboration clients that have no Home Manager program option.
  config = lib.mkIf config.dotfiles.bundles.comms.enable {
    home.packages = with pkgs; [
      discord
      slack
    ];
  };
}
