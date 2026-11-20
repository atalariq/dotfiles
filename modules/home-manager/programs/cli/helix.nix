# Helix as a second modal editor next to nvf. The package comes from nixpkgs
# (its runtime already contains the tree-sitter grammars); this module owns the
# config tree and the theme hand-off.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  source = import ../../lib/source.nix { inherit config; };
in
{
  options.dotfiles.programs.cli.helix.enable = lib.mkEnableOption "Helix editor trial";

  config = lib.mkIf config.dotfiles.programs.cli.helix.enable {
    programs.helix = {
      enable = true;
      # Neovim stays $EDITOR; Helix is installed side by side for comparison.
      defaultEditor = false;
      # `clipboard-provider = "wayland"` in config.toml needs wl-copy/wl-paste.
      extraPackages = [ pkgs.wl-clipboard ];

      # Stylix's Helix target generates themes/stylix.toml and also sets
      # `settings.theme`, which would make Home Manager write config.toml and
      # break the link below. Keep the generated theme, drop the settings half;
      # the config references `theme = "stylix"`.
      settings = lib.mkForce { };
    };

    # The generated theme lives under themes/, so the config files are linked
    # one by one instead of linking the whole helix directory.
    xdg.configFile = {
      "helix/config.toml".source =
        source ./config/helix/config.toml "modules/home-manager/programs/cli/config/helix/config.toml";
      "helix/languages.toml".source =
        source ./config/helix/languages.toml "modules/home-manager/programs/cli/config/helix/languages.toml";
    };
  };
}
