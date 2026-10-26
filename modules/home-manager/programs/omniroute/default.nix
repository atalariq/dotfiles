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
        message = "The local OmniRoute Quadlet requires Linux.";
      }
      {
        assertion = secrets.enable && secrets.files.omniroute != null;
        message = "OmniRoute requires its encrypted environment file before installing the service.";
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
        environmentFile = [ "${config.xdg.configHome}/sops-nix/secrets/omniroute-env" ];
        volumes = [ "${config.xdg.stateHome}/omniroute/data:/app/data" ];
        environment = {
          DATA_DIR = "/app/data";
          PORT = "20128";
          REQUIRE_API_KEY = "true";
          NODE_OPTIONS = "--max-old-space-size=512";
          OMNI_MAX_CONCURRENT_CONNECTIONS = "1";
          OMNIROUTE_MCP_DESCRIPTION_COMPRESSION = "off";
        };
        extraPodmanArgs = [
          "--memory=1g"
          "--security-opt=no-new-privileges"
        ];
        extraConfig = {
          Unit = {
            Requires = [ "sops-nix.service" ];
            After = [
              "sops-nix.service"
              "network-online.target"
            ];
          };
          Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.stateHome}/omniroute/data"}";
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
