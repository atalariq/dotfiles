{ config, pkgs, ... }:
let
  state = "${config.xdg.stateHome}/omniroute";
in
{
  # Import this module explicitly after saving a public image pin in image.json.
  systemd.user.services.omniroute = {
    Unit = {
      Description = "OmniRoute local gateway";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = "${state}/image.json";
    };
    Service = {
      Type = "simple";
      UMask = "0077";
      StateDirectory = "omniroute";
      StateDirectoryMode = "0700";
      ExecStart = pkgs.writeShellScript "omniroute-start" ''
        set -eu
        image=$(${pkgs.jq}/bin/jq -er '
          .image | select(type == "string" and
            test("^docker\\.io/diegosouzapw/omniroute@sha256:[0-9a-f]{64}$"))
        ' ${state}/image.json)
        ${pkgs.coreutils}/bin/mkdir -p ${state}/data
        exec ${pkgs.podman}/bin/podman run --rm --name dotfiles-omniroute --pull=never \
          --userns=keep-id --user "$(${pkgs.coreutils}/bin/id -u):$(${pkgs.coreutils}/bin/id -g)" \
          --publish 127.0.0.1:20128:20128 --memory 10g \
          --cap-drop=ALL --security-opt=no-new-privileges \
          --volume ${state}/data:/app/data:rw \
          --env DATA_DIR=/app/data --env PORT=20128 \
          --env NODE_OPTIONS=--max-old-space-size=8192 \
          --env OMNI_MAX_CONCURRENT_CONNECTIONS=1 --env REQUIRE_API_KEY=true \
          --env OMNIROUTE_MCP_DESCRIPTION_COMPRESSION=off "$image"
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop --ignore --time 30 dotfiles-omniroute";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStopSec = 45;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
