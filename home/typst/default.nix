{ pkgs, ... }:
{
  home.packages = with pkgs; [
    typst
    tinymist
    typstyle
    websocat
    liberation_ttf
  ];
  home.sessionVariables.TYPST_FONT_PATHS = "${pkgs.liberation_ttf}/share/fonts/truetype";
}
