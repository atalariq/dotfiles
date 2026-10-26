{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.dotfiles.programs.codex.enable = lib.mkEnableOption "codex configuration";

  config = lib.mkIf config.dotfiles.programs.codex.enable {

    home.packages = [ pkgs.codex ];
    xdg.configFile."dotfiles/templates/codex.toml".source = ./template.toml;

  };
}
