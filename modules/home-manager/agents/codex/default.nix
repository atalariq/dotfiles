{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.agents.codex.enable = lib.mkEnableOption "codex configuration";

  config = lib.mkIf config.dotfiles.agents.codex.enable {

    home.packages = [ pkgs.codex ];
    home.file.".codex/config.toml".source = dotfilesLib.source ./config/config.toml;

  };
}
