{
  config,
  lib,
  ...
}:
{
  programs.television = lib.mkIf config.programs.television.enable {
    enableFishIntegration = config.programs.fish.enable;
    enableBashIntegration = config.programs.bash.enable;
  };
}
