{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.dotfiles.programs.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.programs.claude.enable {

    home.packages = [ pkgs.claude-code ];
    xdg.configFile."dotfiles/templates/claude.json".source = ./template.json;

  };
}
