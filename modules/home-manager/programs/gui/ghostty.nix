{
  config,
  lib,
  ...
}:
let
  source = import ../../lib/source.nix { inherit config; };
in
{
  options.dotfiles.programs.gui.ghostty.enable = lib.mkEnableOption "Ghostty configuration";

  config = lib.mkIf config.dotfiles.programs.gui.ghostty.enable {
    programs.ghostty = {
      enable = true;
      # The host owns the binary (system package). Home Manager only writes the
      # native configuration and shell integration.
      package = lib.mkForce null;
      systemd.enable = false;
      enableFishIntegration = config.programs.fish.enable;
      # Keep the editable settings in one native file. The generated wrapper
      # config only points at it, so a reload does not need a rebuild.
      settings."config-file" = toString (
        source ./config/ghostty/live.conf "modules/home-manager/programs/gui/config/ghostty/live.conf"
      );
    };
  };
}
