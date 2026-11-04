{
  config,
  lib,
  dotfilesLib,
  ...
}:
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
      # Keep the editable settings/keybinds in one native file. When "kitty"
      # is selected in dotfiles.deployment.liveApps this include points at the
      # checkout; otherwise it points at the immutable store copy.
      extraConfig = ''
        include ${dotfilesLib.sourceFor "kitty" ./config/kitty/live.conf}
      '';
      shellIntegration.enableFishIntegration = config.programs.fish.enable;
    };
    xdg.configFile."kitty/sessions" = {
      source = dotfilesLib.sourceFor "kitty" ./config/kitty/sessions;
    };
  };
}
