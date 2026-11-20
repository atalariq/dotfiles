{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.cli.atuin.enable = lib.mkEnableOption "Atuin shell history";

  config = lib.mkIf config.dotfiles.programs.cli.atuin.enable {
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      # Native Fish config owns its one conditional initialization hook.
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
      settings = {
        # Prefix search keeps the muscle memory of "type the start, get the
        # history that starts the same way"; fuzzy matching buries exact
        # command names under unrelated near-misses.
        search_mode = "prefix";
        enter_accept = true;
        # No Atuin server yet: history stays local on each host. Wave 3 adds
        # the server; until then syncing would only try the public API.
        auto_sync = false;
        daemon = {
          enabled = false;
          autostart = false;
        };
      };
    };
  };
}
