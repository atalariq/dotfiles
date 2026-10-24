{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.agents.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.agents.claude.enable {

    home.packages = [ pkgs.claude-code ];
    home.file.".claude/settings.json".source = dotfilesLib.source ./config/settings.json;
    home.file.".claude/script".source = dotfilesLib.source ./config/script;

  };
}
