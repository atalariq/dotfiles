# Add a handmade Base16 scheme here when the new Wana is ready.
{ pkgs }:
{
  gruvbox-dark = {
    scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";
  };
  gruvbox-light = {
    scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-medium.yaml";
    polarity = "light";
  };
}
