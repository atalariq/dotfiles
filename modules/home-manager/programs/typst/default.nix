{
  pkgs,
  config,
  lib,
  ...
}:
{

  options.dotfiles.programs.typst.enable = lib.mkEnableOption "typst configuration";

  config = lib.mkIf config.dotfiles.programs.typst.enable {

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
