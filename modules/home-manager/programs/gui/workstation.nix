# Convenience aggregate for the NixOS workstation's current GUI app set.
# Every member is still its own module/switch; this only flips their defaults
# so the host can opt in once and disable an individual app when needed.
{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.workstation;
in
{
  options.dotfiles.programs.gui.workstation.enable =
    lib.mkEnableOption "the NixOS workstation GUI application set";

  config = lib.mkIf cfg.enable {
    dotfiles.programs = {
      gui = {
        anki.enable = lib.mkDefault true;
        audacity.enable = lib.mkDefault true;
        blender.enable = lib.mkDefault true;
        brave-origin.enable = lib.mkDefault true;
        discord.enable = lib.mkDefault true;
        espanso.enable = lib.mkDefault true;
        figma-linux.enable = lib.mkDefault true;
        file-roller.enable = lib.mkDefault true;
        gimp.enable = lib.mkDefault true;
        google-chrome.enable = lib.mkDefault true;
        inkscape.enable = lib.mkDefault true;
        kdenlive.enable = lib.mkDefault true;
        kitty.enable = lib.mkDefault true;
        libva-utils.enable = lib.mkDefault true;
        localsend.enable = lib.mkDefault true;
        miro.enable = lib.mkDefault true;
        mpv.enable = lib.mkDefault true;
        nautilus.enable = lib.mkDefault true;
        nicotine-plus.enable = lib.mkDefault true;
        obs-studio.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
        oculante.enable = lib.mkDefault true;
        readest.enable = lib.mkDefault true;
        scrcpy.enable = lib.mkDefault true;
        slack.enable = lib.mkDefault true;
        wdisplays.enable = lib.mkDefault true;
        wl-mirror.enable = lib.mkDefault true;
      };
      cli.ffmpeg.enable = lib.mkDefault true;
    };
  };
}
