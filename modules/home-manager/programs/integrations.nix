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
    enableBashIntegration = false;
  };
  programs.fish.interactiveShellInit = lib.mkIf (
    config.programs.television.enable && config.programs.atuin.enable
  ) (lib.mkAfter "bind ctrl-r _atuin_search");
  programs.bash.initExtra =
    lib.mkIf (config.programs.television.enable && config.programs.bash.enable)
      ''
        source ${pkgs.television}/share/television/completion.bash
      '';
  programs.jujutsu.settings = lib.mkIf config.programs.jujutsu.enable {
    ui.default-command = "log";
  };
}
