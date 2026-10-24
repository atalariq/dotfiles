{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
let
  mpdConfig = pkgs.writeText "mpd.conf" ''
    bind_to_address "127.0.0.1"
    port "6600"
    music_directory "${config.home.homeDirectory}/Music"
    playlist_directory "${config.xdg.dataHome}/mpd/playlist"
    db_file "${config.xdg.dataHome}/mpd/mpd.db"
    state_file "${config.xdg.stateHome}/mpd/mpd.state"
    state_file_interval "1800"
    restore_paused "yes"
    auto_update "yes"
    audio_output {
      type "pipewire"
      name "PipeWire Sound Server"
    }
  '';
in
{

  options.dotfiles.media.mpd.enable = lib.mkEnableOption "mpd configuration";

  config = lib.mkIf config.dotfiles.media.mpd.enable {

    home.packages = [
      pkgs.mpd
      pkgs.mpc
    ];
    # Preserve the queue/state locations, which differ from HM's MPD defaults.
    xdg.configFile."mpd/mpd.conf".source = mpdConfig;
    systemd.user.services.mpd = {
      Unit = {
        Description = "Music Player Daemon";
        After = [ "pipewire.service" ];
      };
      Service = {
        Type = "notify";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.xdg.dataHome}/mpd/playlist ${config.xdg.stateHome}/mpd";
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${mpdConfig}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
    home.sessionVariables = {
      MPD_HOST = "127.0.0.1";
      MPD_PORT = "6600";
    };

  };
}
