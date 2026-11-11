# Native media and productivity services for the homelab. Media services read
# and write the XFS disk as the shared `media` group; the *arr stack and
# qBittorrent use the same `/data` tree so hardlink/atomic move stays possible.
{
  config,
  lib,
  pkgs,
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

  # The persistent directories are bind-mounted from /persist. tmpfiles runs
  # after local-fs and fixes ownership before the services start.
  systemd.tmpfiles.rules = [
    "d /var/lib/atticd 0700 atticd atticd -"
    "d /var/lib/bazarr 0700 bazarr bazarr -"
    "d /var/lib/navidrome 0700 navidrome navidrome -"
    "d /var/lib/prowlarr 0700 prowlarr prowlarr -"
    "d /var/lib/qBittorrent 0755 qbittorrent qbittorrent -"
    "d /var/lib/qBittorrent/qBittorrent 0755 qbittorrent qbittorrent -"
    "d /var/lib/qBittorrent/qBittorrent/config 0755 qbittorrent qbittorrent -"
    "d /var/lib/radarr 0700 radarr radarr -"
    "d /var/lib/sonarr 0700 sonarr sonarr -"
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

  # Seerr is the requests front-end for the *arr stack; it needs the Jellyfin
  # and Sonarr/Radarr API keys, which are entered once in its UI. It stays
  # DynamicUser, so its state lives under /var/lib/private and must not be
  # bind-mounted from /persist.
  services.seerr = {
    enable = true;
    port = 5055;
    stateRevision = 1;
    openFirewall = false;
  };

  # Downloads land on the media disk directly, so a 10 GB release never has to
  # cross the Wi-Fi link twice. Sonarr/Radarr pick the finished files up with
  # Manual Import; this only provides the downloader.
  users.users.aria2 = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/aria2";
  };
  systemd.services.aria2 = {
    description = "aria2 RPC downloader";
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "aria2";
      EnvironmentFile = [ config.sops.secrets.aria2_env.path ];
      Group = "media";
      StateDirectory = "aria2";
      WorkingDirectory = "/data/media/downloads/incoming";
      ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=/dev/null --enable-rpc --rpc-listen-all --rpc-allow-origin-all --rpc-secret=${"$"}{ARIA2_RPC_SECRET} --dir=/data/media/downloads/incoming --continue=true --max-concurrent-downloads=5 --file-allocation=none";
      Restart = "on-failure";
    };
  };

  environment.systemPackages = [ pkgs.beets ];

  # Phones on the LAN reach the same services the tailnet does; the rest of
  # the firewall stays closed. aria2's RPC is tailnet-only.
  networking.firewall.allowedTCPPorts = [ 5055 ];
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6800 ];

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
      name = "Seerr";
      port = 5055;
      note = "Media requests";
    }
    {
      name = "aria2 RPC";
      port = 6800;
      note = "Direct downloads (tailnet only)";
    }
    {
      name = "Attic";
      port = 8081;
      note = "Nix cache (tailnet only)";
    }
  ];
}
