# Media stack for the homelab. Jellyfin reads the XFS media disk; its
# configuration and cache stay on the SSD so library scans are not limited by
# the old spinning disk. The service is ordered after `data.mount` so it never
# starts with an empty library when the HDD is missing.
{
  users.groups.media = { };

  users.users.jellyfin.extraGroups = [
    "media"
    "video"
    "render"
  ];

  services.jellyfin = {
    enable = true;
    # The web UI is exposed to the LAN on 8096; Tailscale reaches it through
    # the trusted interface without opening the ports on every interface.
    openFirewall = false;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    transcoding = {
      enableHardwareEncoding = true;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        vp9 = true;
      };
      maxConcurrentStreams = 2;
      throttleTranscoding = true;
    };
  };

  # Phones on the LAN need 8096; 7359 is Jellyfin's server discovery beacon.
  networking.firewall = {
    allowedTCPPorts = [ 8096 ];
    allowedUDPPorts = [ 7359 ];
  };

  systemd.services.jellyfin = {
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
  };

  systemd.tmpfiles.rules = [
    "d /data/media 2775 atalariq media -"
    "d /data/media/movies 2775 atalariq media -"
    "d /data/media/series 2775 atalariq media -"
    "d /data/media/music 2775 atalariq media -"
  ];
}
