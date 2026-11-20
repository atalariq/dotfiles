{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.development.direnv.enable =
    lib.mkEnableOption "direnv with nix-direnv and shell integrations";

  config = lib.mkIf config.dotfiles.programs.development.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
