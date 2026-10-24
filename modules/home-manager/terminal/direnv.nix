{ config, lib, ... }: {
  options.dotfiles.terminal.direnv.enable =
    lib.mkEnableOption "direnv with cached flake environments";
  config = lib.mkIf config.dotfiles.terminal.direnv.enable {
    xdg.configFile."fish/conf.d/00-direnv.fish" = lib.mkIf config.dotfiles.terminal.fish.enable {
      text = ''
        if status is-interactive; and command -q direnv
          direnv hook fish | source
        end
      '';
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = config.dotfiles.terminal.bash.enable;
      # The native Fish fragment above owns the hook; programs.fish is not used.
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
  };
}
