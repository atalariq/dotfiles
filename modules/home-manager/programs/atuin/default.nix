{
  config,
  lib,
  dotfilesLib,
  ...
}:
{

  config = lib.mkIf config.programs.atuin.enable {

    programs.bash.initExtra = lib.mkIf config.programs.bash.enable (
      lib.mkAfter ''
        eval "$(${config.programs.atuin.package}/bin/atuin init bash)"
      ''
    );
    programs.atuin = {
      flags = [ "--disable-up-arrow" ];
      # Native Fish config owns its one conditional initialization hook.
      enableFishIntegration = config.programs.fish.enable;
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

  };
}
