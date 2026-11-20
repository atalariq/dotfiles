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
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  configText = builtins.readFile ./config/helix/config.toml;
in
{
  options.dotfiles.programs.cli.helix.enable = lib.mkEnableOption "Helix editor trial";

  config = lib.mkIf config.dotfiles.programs.cli.helix.enable {
    programs.helix = {
      enable = true;
      # Neovim stays $EDITOR; Helix is installed side by side for comparison.
      defaultEditor = false;
      # `clipboard-provider = "wayland"` needs wl-copy/wl-paste; macOS uses
      # the native clipboard provider instead.
      extraPackages = lib.optionals isLinux [ pkgs.wl-clipboard ];

      # Stylix's Helix target generates themes/stylix.toml and also sets
      # `settings.theme`, which would make Home Manager write config.toml and
      # break the link below. Keep the generated theme, drop the settings half;
      # the config references `theme = "stylix"`.
      settings = lib.mkForce { };
    };

    # The generated theme lives under themes/, so the config files are linked
    # one by one instead of linking the whole helix directory.
    xdg.configFile = {
      "helix/config.toml" =
        if isLinux then
          {
            source = source ./config/helix/config.toml "modules/home-manager/programs/cli/config/helix/config.toml";
          }
        else
          {
            text =
              lib.replaceStrings [ ''clipboard-provider = "wayland"'' ] [ ''clipboard-provider = "clipboard"'' ]
                configText;
          };
      "helix/languages.toml".source =
        source ./config/helix/languages.toml "modules/home-manager/programs/cli/config/helix/languages.toml";
    };
  };
}
