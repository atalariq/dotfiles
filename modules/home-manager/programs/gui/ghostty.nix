{
  config,
  lib,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.ghostty;
in
{
  options.dotfiles.programs.gui.ghostty.enable = lib.mkEnableOption "Ghostty configuration";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      # The host owns the binary (system package). Home Manager only writes the
      # native configuration and shell integration.
      package = lib.mkForce null;
      systemd.enable = false;
      enableFishIntegration = config.programs.fish.enable;
      # Keep the editable settings in one live file. The generated wrapper
      # config only points at it, so a reload does not need a rebuild.
      settings."config-file" = toString (dotfilesLib.sourceFor "ghostty" ./config/ghostty/live.conf);
    };
  };
}
