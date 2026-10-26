{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.look.homeModules.default
  ];
  programs = {
    television = lib.mkIf config.programs.television.enable {
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;
    };
    nix-search-tv = lib.mkIf config.programs.television.enable {
      enable = true;
      enableTelevisionIntegration = true;
    };
    jujutsu.settings = lib.mkIf config.programs.jujutsu.enable {
      ui.default-command = "log";
    };
  };
}
