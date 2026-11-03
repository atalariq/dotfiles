# Native media and productivity services for the homelab. Media services read
# and write the XFS disk as the shared `media` group; the *arr stack and
# qBittorrent use the same `/data` tree so hardlink/atomic move stays possible.
{
  users.users.navidrome.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.bazarr.extraGroups = [ "media" ];
  users.users.qbittorrent.extraGroups = [ "media" ];

  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/data/media/music/library";
    };
  };

  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;
  services.bazarr.enable = true;

  services.qbittorrent = {
    enable = true;
    extraArgs = [ "--confirm-legal-notice" ];
    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent = {
        "Session\\DefaultSavePath" = "/data/media/downloads";
      };
    };
  };

  users.groups.actual = { };
  users.users.actual = {
    isSystemUser = true;
    group = "actual";
  };

  services.actual = {
    enable = true;
    user = "actual";
    group = "actual";
    settings = {
      hostname = "0.0.0.0";
      port = 5006;
      dataDir = "/var/lib/actual";
    };
  };

  services.memos = {
    enable = true;
    settings = {
      MEMOS_ADDR = "0.0.0.0";
      MEMOS_PORT = "5230";
      MEMOS_DATA = "/var/lib/memos";
      MEMOS_DRIVER = "sqlite";
      MEMOS_INSTANCE_URL = "http://homelab-x456urk:5230";
    };
  };

  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = "homelab-x456urk";
    address = "0.0.0.0";
    port = 3456;
  };

  systemd.services = {
    navidrome = {
      after = [ "data.mount" ];
      requires = [ "data.mount" ];
    };
    sonarr = {
      after = [ "data.mount" ];
      requires = [ "data.mount" ];
    };
    radarr = {
      after = [ "data.mount" ];
      requires = [ "data.mount" ];
    };
    bazarr = {
      after = [ "data.mount" ];
      requires = [ "data.mount" ];
    };
    qbittorrent = {
      after = [ "data.mount" ];
      requires = [ "data.mount" ];
    };
  };
}
