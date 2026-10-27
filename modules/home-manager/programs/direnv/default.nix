{
  config,
  lib,
  ...
}:
{
  programs.direnv = {
    enable = lib.mkDefault true;
    nix-direnv.enable = lib.mkIf config.programs.direnv.enable true;
    enableBashIntegration = lib.mkIf config.programs.direnv.enable config.programs.bash.enable;
    enableFishIntegration = lib.mkIf config.programs.direnv.enable config.programs.fish.enable;
    enableZshIntegration = lib.mkIf config.programs.direnv.enable config.programs.zsh.enable;
  };
}
