{ pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    osu-lazer
    gzdoom
    mcpelauncher-ui-qt
    mgba
    mednafen
    snes9x
    pcsx2
  ];
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    settings = {
      fps = true;
      frame_timing = true;
      cpu_temp = true;
      gpu_temp = true;
    };
  };
}
