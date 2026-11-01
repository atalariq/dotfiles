{
  config,
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

    # nix-search-tv pairs with television; both share the same enable gate.
    programs.nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;
    };
  };
}
