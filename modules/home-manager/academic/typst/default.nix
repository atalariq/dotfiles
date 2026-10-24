{
  pkgs,
  config,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.academic.typst.enable = lib.mkEnableOption "typst configuration";

  config = lib.mkIf config.dotfiles.academic.typst.enable {

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
