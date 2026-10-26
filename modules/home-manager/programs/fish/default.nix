{ config, lib, ... }:
{
  programs.fish = lib.mkIf config.programs.fish.enable {
    generateCompletions = true;
  };
}
