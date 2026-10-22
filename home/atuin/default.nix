{ ... }:
{
  programs.atuin = {
    enable = true;
    # Native Fish config owns its one conditional initialization hook.
    enableFishIntegration = false;
    enableBashIntegration = false;
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
}
