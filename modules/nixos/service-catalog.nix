# One declarative list for the SSH reminder and the on-demand status command.
# Hosts own the actual service declarations; this module only renders them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.services.endpoints;
  host = config.networking.hostName;
  endpoint = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; };
      port = lib.mkOption { type = lib.types.port; };
      protocol = lib.mkOption {
        type = lib.types.enum [
          "http"
          "https"
        ];
        default = "http";
      };
      path = lib.mkOption {
        type = lib.types.str;
        default = "/";
      };
      note = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };
  lines = map (
    entry:
    "  ${entry.name}: ${entry.protocol}://${host}:${toString entry.port}${entry.path}  ${entry.note}"
  ) cfg;
  motd = ''
    ${host} — services

    ${lib.concatStringsSep "\n" lines}

    Access: ssh homelab-ts (Tailscale) / ssh homelab-lan (LAN)
    Details: homelab-status
  '';
  # users.motd is consumed by pam_motd at login, not written to /etc/motd in
  # current NixOS, so homelab-status prints the same text from the store.
  motdFile = pkgs.writeText "motd" motd;
in
{
  options.dotfiles.services.endpoints = lib.mkOption {
    type = lib.types.listOf endpoint;
    default = [ ];
    description = "Services shown in the SSH MOTD and homelab-status.";
  };

  config = lib.mkIf (cfg != [ ]) {
    users.motd = motd;
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "homelab-status" ''
        cat ${motdFile}
        echo
        echo "Failed units:"
        ${pkgs.systemd}/bin/systemctl --failed --no-pager
      '')
    ];
  };
}
