{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];
  options.dotfiles.desktop.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";
  config = lib.mkIf config.dotfiles.desktop.noctalia.enable {
    assertions = [
      {
        assertion = config.dotfiles.desktop.appearance.enable;
        message = "Noctalia requires the shared appearance module.";
      }
    ];
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      checkConfig = true;
      settings = {
        shell = {
          polkit_agent = true;
          font = config.stylix.fonts.sansSerif.name;
        };
        lockscreen = {
          enabled = true;
          fingerprint = true;
          lock_before_suspend = true;
        };
      };
    };
  };
}
