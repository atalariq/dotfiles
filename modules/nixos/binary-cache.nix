{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.system.binary-cache;
in
{
  options.dotfiles.system.binary-cache = {
    server = {
      enable = lib.mkEnableOption "the Attic binary cache server";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port atticd listens on; only the tailnet reaches it.";
      };
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Root-only runtime file with ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64.";
      };
    };
    client = {
      enable = lib.mkEnableOption "the Attic binary cache client";
      url = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Substituter URL, e.g. http://homelab-x456urk:8080/main.";
      };
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Cache public key printed by `attic cache info <name>`.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      assertions = [
        {
          assertion = cfg.server.environmentFile != null;
          message = "The Attic server needs an environmentFile with the JWT signing secret.";
        }
      ];

      services.atticd = {
        enable = true;
        environmentFile = cfg.server.environmentFile;
        settings = {
          listen = "[::]:${toString cfg.server.port}";
          # Local storage and SQLite are enough for one host; the database and
          # storage live under /var/lib/atticd so impermanence can persist them.
          database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
          storage = {
            type = "local";
            path = "/var/lib/atticd/storage";
          };
          compression.type = "zstd";
          "garbage-collection".interval = "12 hours";
        };
      };

      # Nothing on the shared LAN (or the internet) may reach atticd.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.server.port ];
    })

    (lib.mkIf cfg.client.enable {
      nix.settings = {
        extra-substituters = [ cfg.client.url ];
        extra-trusted-public-keys = [ cfg.client.publicKey ];
      };
      environment.systemPackages = [ pkgs.attic-client ];
    })
  ];
}
