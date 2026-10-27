{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.mangohud.enable = lib.mkEnableOption "MangoHud overlay";

  config = lib.mkIf config.dotfiles.programs.mangohud.enable {
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
  };
}
