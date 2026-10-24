{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.codex.enable = lib.mkEnableOption "codex configuration";

  config = lib.mkIf config.dotfiles.programs.codex.enable {

    home.packages = [ pkgs.codex ];
    home.file.".codex/config.toml".source = dotfilesLib.source ./config/config.toml;

  };
}
