# One option owns the whole local music stack:
#   - mpd        the daemon (queue, database, state, PipeWire output)
#   - mpc/rmpc   command-line and terminal clients on 127.0.0.1:6600
#   - mpDris2    MPRIS bridge so the Noctalia media widget and XF86Audio keys
#                control playback through the session bus
#   - mpdscribble Last.fm scrobbler, gated on a credential file kept outside
#                the Nix store
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
  # mpdscribble reads $XDG_CONFIG_HOME/mpdscribble/mpdscribble.conf first.
  scrobblerConfig = "${config.xdg.configHome}/mpdscribble/mpdscribble.conf";
in
{
  options.dotfiles.programs.mpd.enable =
    lib.mkEnableOption "the MPD daemon with the rmpc client, mpDris2 MPRIS bridge and mpdscribble Last.fm scrobbler";

  config = lib.mkIf config.dotfiles.programs.mpd.enable {

    home.packages = [
      pkgs.mpd
      pkgs.mpc
      pkgs.rmpc
      # Installs the mpDris2 D-Bus activation file; the unit below is the
      # systemd counterpart it delegates to.
      pkgs.mpdris2
      pkgs.mpdscribble
    ];
    # Preserve the queue/state locations, which differ from HM's MPD defaults.
    xdg.configFile."mpd/mpd.conf".source = mpdConfig;
    # rmpc keeps its own config tree; Stylix replaces the baseline palette in
    # both config.ron and themes/*.ron.
    xdg.configFile."rmpc".source = dotfilesLib.themedDirectory ./config/rmpc;
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
    # MPRIS bridge: exposes org.mpris.MediaPlayer2.mpd on the session bus for
    # the Noctalia media widget and the XF86Audio key handling.
    systemd.user.services.mpDris2 = {
      Unit = {
        Description = "MPRIS 2 bridge for the Music Player Daemon";
        After = [ "mpd.service" ];
        Requires = [ "mpd.service" ];
        PartOf = [
          "mpd.service"
          "graphical-session.target"
        ];
      };
      Service = {
        ExecStart = "${pkgs.mpdris2}/bin/mpDris2 --use-journal";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
    # Last.fm scrobbling. The unit stays inactive until a credential file
    # exists at the path below; that file is never generated from Nix. Either
    # provision it through dotfiles.services.secrets.files.lastfm (decrypted
    # to the same path, mode 0600) or write it manually, then restart the unit:
    #   systemctl --user restart mpdscribble
    # The offline Last.fm journal is mpdscribble's own file under
    # $XDG_CACHE_HOME/mpdscribble/mpdscribble.cache unless the config sets
    # `journal =`.
    systemd.user.services.mpdscribble = {
      Unit = {
        Description = "Last.fm scrobbler for the Music Player Daemon";
        After = [ "mpd.service" ];
        Requires = [ "mpd.service" ];
        PartOf = [ "mpd.service" ];
        ConditionPathExists = scrobblerConfig;
      };
      Service = {
        ExecStart = "${pkgs.mpdscribble}/bin/mpdscribble --no-daemon --log - --conf ${scrobblerConfig}";
        Restart = "on-failure";
        RestartSec = 10;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
      Install.WantedBy = [ "default.target" ];
    };
    home.sessionVariables = {
      MPD_HOST = "127.0.0.1";
      MPD_PORT = "6600";
    };

  };
}
