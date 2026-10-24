{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.yazi.enable = lib.mkEnableOption "yazi configuration";

  config = lib.mkIf config.dotfiles.terminal.yazi.enable {

    home.packages = with pkgs; [
      yazi
      ouch
      mediainfo
      ffmpeg
      imagemagick
    ];
    programs.yazi = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    xdg.configFile =
      lib.mapAttrs'
        (name: _: lib.nameValuePair "yazi/${name}" { source = dotfilesLib.source (./config + "/${name}"); })
        (lib.filterAttrs (name: _: name != "theme.toml" && name != "flavors") (builtins.readDir ./config));

  };
}
