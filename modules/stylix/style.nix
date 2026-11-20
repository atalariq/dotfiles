{
  pkgs,
  theme ? "gruvbox-dark",
}:
let
  selected = (import ./schemes.nix { inherit pkgs; }).${theme};
in
{
  enable = true;
  autoEnable = false;
  base16Scheme = selected.scheme;
  inherit (selected) polarity;
  fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
    sansSerif = {
      package = pkgs.inter;
      name = "Inter";
    };
    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };
    sizes.terminal = 12;
  };
  cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Dark";
  };
}
