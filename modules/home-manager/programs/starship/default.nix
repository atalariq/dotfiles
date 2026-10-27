{
  config,
  lib,
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
    # Per-shell badge with its own colour. The native shell module only accepts
    # one colour and always renders next to the character, so each shell gets a
    # custom module gated on STARSHIP_SHELL (exported by every starship init).
    # Custom modules expand at $custom, i.e. at the end of the info line.
    "shell"."disabled" = true;
    "custom"."shell-fish" = {
      "command" = "true";
      "when" = ''test "$STARSHIP_SHELL" = fish'';
      "format" = "[fish](bold cyan) ";
    };
    "custom"."shell-bash" = {
      "command" = "true";
      "when" = ''test "$STARSHIP_SHELL" = bash'';
      "format" = "[bash](bold green) ";
    };
    "custom"."shell-zsh" = {
      "command" = "true";
      "when" = ''test "$STARSHIP_SHELL" = zsh'';
      "format" = "[zsh](bold yellow) ";
    };
    palettes.${if config.dotfiles.appearance.enable then "base16" else "dotfiles"} = lib.mapAttrs (
      _: role: colours.${role}
    ) roles;

  };
}
