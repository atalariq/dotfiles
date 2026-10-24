{
  config,
  lib,
  pkgs,
  ...
}:
let
  script = import ../../../lib/runtime-script.nix { inherit pkgs lib; };
in
{
  options.dotfiles.programs.status.enable = lib.mkEnableOption "status runtime helpers";
  config = lib.mkIf config.dotfiles.programs.status.enable {
    home.packages = [
      (script {
        name = "server-mode";
        source = ./_terminal-scripts/server-mode;
        runtimeInputs = with pkgs; [
          systemd
          coreutils
          gnugrep
          gnused
          gawk
          procps
          iproute2
          power-profiles-daemon
          util-linux
        ];
      })
      (script {
        name = "server-status";
        source = ./_terminal-scripts/server-status;
        runtimeInputs = with pkgs; [
          systemd
          coreutils
          gnugrep
          gnused
          gawk
          procps
          iproute2
          power-profiles-daemon
          util-linux
        ];
      })
    ];
    home.file = {
      ".local/script/server-mode".source =
        pkgs.writeShellScript "compat" "#!/bin/sh\nexec ${config.home.profileDirectory}/bin/server-mode \"$@\"\n";
      ".local/script/server-status".source =
        pkgs.writeShellScript "compat" "#!/bin/sh\nexec ${config.home.profileDirectory}/bin/server-status \"$@\"\n";
    };
  };
}
