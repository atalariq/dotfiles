{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.development.godot.enable = lib.mkEnableOption "Game Development bundle";

  config = lib.mkIf config.dotfiles.programs.development.godot.enable {
    home.packages = with pkgs; [
      godot
    ];
  };
}
