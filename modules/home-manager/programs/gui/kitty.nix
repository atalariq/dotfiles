{
  config,
  lib,
  ...
}:
let
  source = import ../../lib/source.nix { inherit config; };
in
{
  options.dotfiles.programs.gui.kitty.enable = lib.mkEnableOption "kitty configuration";

  config = lib.mkIf config.dotfiles.programs.gui.kitty.enable {
    programs.kitty = {
      enable = true;
      # The binary belongs to the host (system package on NixOS, Homebrew cask
      # on macOS). Home Manager keeps only the generated config and shell
      # integration.
      package = lib.mkForce null;
      settings = {
        "shell" = lib.mkIf config.programs.fish.enable (lib.getExe config.programs.fish.package);
      };
      # Keep the editable settings/keybinds in one native file. The generated
      # wrapper config only points at it, so a reload does not need a rebuild.
      extraConfig = ''
        include ${source ./config/kitty/live.conf "modules/home-manager/programs/gui/config/kitty/live.conf"}
      '';
      shellIntegration.enableFishIntegration = config.programs.fish.enable;
    };
    xdg.configFile."kitty/sessions" = {
      source = source ./config/kitty/sessions "modules/home-manager/programs/gui/config/kitty/sessions";
    };
  };
}
