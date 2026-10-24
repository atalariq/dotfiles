{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf config.dotfiles.programs.opencode.enable {

    home.packages = with pkgs; [ opencode ];
    # Keep the directory writable for local plugins and their dependencies.
    xdg.configFile."opencode/opencode.jsonc".source = dotfilesLib.source ./config/opencode.jsonc;
    xdg.configFile."opencode/cli.json".source = dotfilesLib.source ./config/cli.json;

  };
}
