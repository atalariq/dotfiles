{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.working.slack.enable = lib.mkEnableOption "slack";
  config = lib.mkIf config.dotfiles.working.slack.enable { home.packages = with pkgs; [ slack ]; };
}
