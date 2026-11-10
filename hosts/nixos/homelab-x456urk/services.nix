# Native media and productivity services for the homelab. Media services read
# and write the XFS disk as the shared `media` group; the *arr stack and
# qBittorrent use the same `/data` tree so hardlink/atomic move stays possible.
{
  lib,
  ...
}:
{
  users.users.navidrome.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.bazarr.extraGroups = [ "media" ];
  users.users.qbittorrent.extraGroups = [ "media" ];

  # These services normally use DynamicUser. Persistent bind mounts under
  # /persist need a stable UID, so give them fixed service accounts instead.
  users.groups.atticd = { };
  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };
  users.groups.prowlarr = { };
  users.users.prowlarr = {
    isSystemUser = true;
    group = "prowlarr";
  };
  users.groups.vikunja = { };
  users.users.vikunja = {
    isSystemUser = true;
    group = "vikunja";
  };

  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/data/media/music";
    };
  };

  services.sonarr.enable = true;
  services.radarr = {
    enable = true;
    # Keep Radarr's native data directly under the persisted state directory.
    dataDir = "/var/lib/radarr";
  };
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

  # The persistent directories are bind-mounted from /persist. tmpfiles runs
  # after local-fs and fixes ownership before the services start.
  systemd.tmpfiles.rules = [
    "d /var/lib/actual 0700 actual actual -"
    "d /var/lib/actual/server-files 0700 actual actual -"
    "d /var/lib/actual/user-files 0700 actual actual -"
    "d /var/lib/atticd 0700 atticd atticd -"
    "d /var/lib/bookorbit 0755 root root -"
    "d /var/lib/bookorbit/postgres 0700 999 999 -"
    "d /var/lib/bookorbit/app 0755 1000 996 -"
    "d /var/lib/bazarr 0700 bazarr bazarr -"
    "d /var/lib/memos 0750 memos memos -"
    "d /var/lib/navidrome 0700 navidrome navidrome -"
    "d /var/lib/prowlarr 0700 prowlarr prowlarr -"
    "d /var/lib/qBittorrent 0755 qbittorrent qbittorrent -"
    "d /var/lib/qBittorrent/qBittorrent 0755 qbittorrent qbittorrent -"
    "d /var/lib/qBittorrent/qBittorrent/config 0755 qbittorrent qbittorrent -"
    "d /var/lib/radarr 0700 radarr radarr -"
    "d /var/lib/sonarr 0700 sonarr sonarr -"
    "d /var/lib/vikunja 0700 vikunja vikunja -"
  ];

  systemd.services = {
    atticd.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "atticd";
      Group = "atticd";
    };
    prowlarr.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "prowlarr";
      Group = "prowlarr";
    };
    vikunja.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "vikunja";
      Group = "vikunja";
    };

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
      serviceConfig.StateDirectory = "radarr";
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

  # Rendered into the SSH MOTD and `homelab-status`.
  dotfiles.services.endpoints = [
    {
      name = "Jellyfin";
      port = 8096;
      note = "Movies & Series (LAN/tailnet)";
    }
    {
      name = "Navidrome";
      port = 4533;
      note = "Music";
    }
    {
      name = "BookOrbit";
      port = 3000;
      note = "Books";
    }
    {
      name = "Actual";
      port = 5006;
      note = "Finance";
    }
    {
      name = "Memos";
      port = 5230;
      note = "Notes";
    }
    {
      name = "Vikunja";
      port = 3456;
      note = "Tasks";
    }
    {
      name = "Sonarr";
      port = 8989;
      note = "TV";
    }
    {
      name = "Radarr";
      port = 7878;
      note = "Movies";
    }
    {
      name = "Prowlarr";
      port = 9696;
      note = "Indexers";
    }
    {
      name = "Bazarr";
      port = 6767;
      note = "Subtitles";
    }
    {
      name = "qBittorrent";
      port = 8080;
      note = "Downloads";
    }
    {
      name = "Attic";
      port = 8081;
      note = "Nix cache (tailnet only)";
    }
  ];
}
