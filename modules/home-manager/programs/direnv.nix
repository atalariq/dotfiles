{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.direnv = lib.mkIf config.programs.direnv.enable {
    nix-direnv.enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = false;
  };
}
