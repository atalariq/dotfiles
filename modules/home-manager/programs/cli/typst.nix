{
  pkgs,
  config,
  lib,
  ...
}:
{

  options.dotfiles.programs.cli.typst.enable = lib.mkEnableOption "typst configuration";

  config = lib.mkIf config.dotfiles.programs.cli.typst.enable {

    home.packages = with pkgs; [
      typst
      tinymist
      typstyle
      websocat
      newcomputermodern
    ];
    home.sessionVariables.TYPST_FONT_PATHS = "${pkgs.newcomputermodern}/share/fonts";

  };
}
