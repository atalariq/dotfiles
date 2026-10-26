{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.omniroute;
  secrets = config.dotfiles.services.secrets;
in
{
  options.dotfiles.programs.omniroute = {
    enable = lib.mkEnableOption "OmniRoute rootless local gateway";
    image = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.strMatching "docker\\.io/diegosouzapw/omniroute@sha256:[0-9a-f]{64}"
      );
      default = "docker.io/diegosouzapw/omniroute@sha256:90f903d7e9245973dc23f7f0a3afc0c63502c9bd25961097843361689df6474b"; # 3.8.52, linux/amd64
      description = "Verified OCI digest; null leaves the service uninstalled during onboarding.";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.image != null) {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "The local OmniRoute user service requires Linux.";
      }
    ];
    services.podman = {
      enable = true;
      autoUpdate.enable = false;
      containers.omniroute = {
        image = cfg.image;
        autoStart = true;
        ports = [ "127.0.0.1:20128:20128" ];
        userNS = "keep-id";
        dropCapabilities = [ "ALL" ];
        # The pinned native bootstrap creates crypto material in DATA_DIR/server.env
        # when no startup environment is supplied. Preserve this with the database.
        environmentFile = lib.optional (
          secrets.enable && secrets.files.omniroute != null
        ) "${config.xdg.configHome}/sops-nix/secrets/omniroute-env";
        volumes = [ "${config.xdg.stateHome}/omniroute/data:/app/data" ];
        environment = {
          DATA_DIR = "/app/data";
          PORT = "20128";
          REQUIRE_API_KEY = "true";
          # Native heap knob; leave room for SQLite, buffers and worker overhead.
          OMNIROUTE_MEMORY_MB = "2048";
          # Allow foreground agents, reviewers and auxiliary requests to overlap.
          # This is backpressure, not a provider spending limit.
          OMNI_MAX_CONCURRENT_CONNECTIONS = "8";
          OMNIROUTE_MCP_DESCRIPTION_COMPRESSION = "off";
        };
        extraPodmanArgs = [
          "--memory=3g"
          "--security-opt=no-new-privileges"
        ];
        extraConfig = {
          Unit = {
            Requires = lib.optional (secrets.enable && secrets.files.omniroute != null) "sops-nix.service";
            After = [
              "network-online.target"
            ]
            ++ lib.optional (secrets.enable && secrets.files.omniroute != null) "sops-nix.service";
          };
          Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg "${config.xdg.stateHome}/omniroute"} ${lib.escapeShellArg "${config.xdg.stateHome}/omniroute/data"}";
            Restart = "on-failure";
            RestartSec = 10;
            TimeoutStopSec = 45;
            UMask = "0077";
          };
        };
      };
    };
  };
}
