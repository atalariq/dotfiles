{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.atuin.enable = lib.mkEnableOption "Atuin shell history";

  config = lib.mkIf config.dotfiles.programs.atuin.enable {
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      # Native Fish config owns its one conditional initialization hook.
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = false;
      settings = {
        search_mode = "fuzzy";
        enter_accept = true;
        auto_sync = true;
        sync_address = "https://api.atuin.sh";
        sync.records = true;
        daemon = {
          enabled = true;
          autostart = true;
        };
      };
    };
  };
}
