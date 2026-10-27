{ config, lib, ... }:
{
  options.dotfiles.services.syncthing.enable =
    lib.mkEnableOption "Syncthing with a loopback GUI and no implicit folders";

  config = lib.mkIf config.dotfiles.services.syncthing.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false;
      overrideFolders = false;
      settings = {
        folders = { };
        options.startBrowser = false;
      };
    };
    # Only explicitly shared folders sync; the default ~/Sync folder stays off.
    systemd.user.services.syncthing.Service.Environment = [ "STNODEFAULTFOLDER=1" ];
  };
}
