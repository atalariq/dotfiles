{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.look.homeModules.default
  ];
  programs.television = lib.mkIf config.programs.television.enable {
    enableFishIntegration = config.programs.fish.enable;
    enableBashIntegration = config.programs.bash.enable;
  };
  programs.jujutsu.settings = lib.mkIf config.programs.jujutsu.enable {
    ui.default-command = "log";
  };
}
