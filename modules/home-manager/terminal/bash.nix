{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.terminal.bash.enable =
    lib.mkEnableOption "Bash login and interactive configuration";
  config = lib.mkIf config.dotfiles.terminal.bash.enable {
    home.sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.local/script"
    ];
    programs.bash = {
      enable = true;
      # HM's login profile exports the shared session environment. Never exec
      # Fish from bashrc: noninteractive SSH and automation must remain Bash.
      initExtra = lib.optionalString config.dotfiles.terminal.starship.enable ''
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
    };
  };
}
