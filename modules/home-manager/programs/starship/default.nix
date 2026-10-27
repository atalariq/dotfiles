{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseline = import ../../../stylix/source-palette.nix;
  colours =
    if config.dotfiles.appearance.enable then
      config.lib.stylix.colors.withHashtag
    else
      lib.mapAttrs (_: value: "#${value}") baseline;
  # Keep the established prompt's role names while using Stylix's Base16 palette.
  roles = {
    blue = "base0D";
    red = "base08";
    green = "base0B";
    yellow = "base0A";
    cyan = "base0C";
    magenta = "base0E";
    white = "base05";
    black = "base00";
    text = "base05";
    subtext1 = "base04";
    subtext0 = "base04";
    overlay2 = "base03";
    overlay1 = "base03";
    overlay0 = "base03";
    surface2 = "base02";
    surface1 = "base01";
    surface0 = "base01";
    base = "base00";
    mantle = "base00";
    crust = "base00";
    rosewater = "base06";
    flamingo = "base08";
    pink = "base0E";
    mauve = "base0E";
    maroon = "base08";
    peach = "base09";
    teal = "base0C";
    sky = "base0C";
    sapphire = "base0D";
    lavender = "base07";
  };
in
{
  programs.starship.settings = lib.mkIf config.programs.starship.enable {
    "$schema" = "https://starship.rs/config-schema.json";
    "palette" = if config.dotfiles.appearance.enable then "base16" else "dotfiles";
    "scan_timeout" = 500;
    "command_timeout" = 1000;
    "container" = {
      "format" = "[$symbol \\[$name\\]]($style) ";
    };
    "hostname" = {
      "ssh_only" = false;
      "format" = "on [$hostname](bold red) [$ssh_symbol](bold blue) ";
      "disabled" = false;
    };
    "shell" = {
      "disabled" = false;
      "style" = "bold blue";
    };
    palettes.${if config.dotfiles.appearance.enable then "base16" else "dotfiles"} = lib.mapAttrs (
      _: role: colours.${role}
    ) roles;

  };
}
