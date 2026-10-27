{
  config,
  lib,
  ...
}:
{
  programs.fzf = lib.mkIf config.programs.fzf.enable {
    enableFishIntegration = false; # Television owns Ctrl-T, Atuin owns Ctrl-R.
    enableBashIntegration = false;
    enableZshIntegration = false;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
  };
}
