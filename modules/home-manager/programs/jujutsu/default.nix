{
  config,
  lib,
  ...
}:
{
  programs.jujutsu.settings = lib.mkIf config.programs.jujutsu.enable {
    ui.default-command = "log";
  };
}
