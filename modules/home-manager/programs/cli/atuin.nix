{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.cli.atuin = {
    enable = lib.mkEnableOption "Atuin shell history";
    server = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Sync server URL; empty keeps history local.";
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Atuin account name; empty leaves the client prompt in charge.";
    };
    autoSync = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Sync after every command once the account is logged in.";
    };
  };

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
        auto_sync = config.dotfiles.programs.cli.atuin.autoSync;
        daemon = {
          enabled = false;
          autostart = false;
        };
      }
      // lib.optionalAttrs (config.dotfiles.programs.cli.atuin.server != "") {
        sync_address = config.dotfiles.programs.cli.atuin.server;
      }
      // lib.optionalAttrs (config.dotfiles.programs.cli.atuin.username != "") {
        username = config.dotfiles.programs.cli.atuin.username;
      };
    };
  };
}
