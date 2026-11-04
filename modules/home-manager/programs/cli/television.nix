{
  config,
  dotfilesLib,
  lib,
  ...
}:
{
  options.dotfiles.programs.cli.television.enable = lib.mkEnableOption "television configuration";

  config = lib.mkIf config.dotfiles.programs.cli.television.enable {
    programs.television = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;
    };

    # Config, channels and keybindings are one native tree. In live mode the
    # directory links to the checkout, so `tv` (and any channel) can be tuned
    # without a rebuild. HM's generated `settings`/`channels` options stay
    # unused on purpose: they would make the tree immutable.
    xdg.configFile."television".source = dotfilesLib.sourceFor "television" ./config/television;

    # nix-search-tv pairs with television. Its channel is part of the native
    # tree above, so HM must not also generate `cable/nix-search-tv.toml`.
    programs.nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = false;
    };
  };
}
