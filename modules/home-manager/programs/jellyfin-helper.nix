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
  options.dotfiles.programs.jellyfin-helper.enable =
    lib.mkEnableOption "jellyfin-helper runtime helpers";
  config = lib.mkIf config.dotfiles.programs.jellyfin-helper.enable {
    home.packages = [
      (script {
        name = "jellyfin-start-server";
        source = ./_media-scripts/jellyfin-start-server;
        runtimeInputs = with pkgs; [
          coreutils
          systemd
        ];
      })
    ];
    home.file = {
      ".local/script/jellyfin-start-server".source =
        pkgs.writeShellScript "compat" "#!/bin/sh\nexec ${config.home.profileDirectory}/bin/jellyfin-start-server \"$@\"\n";
    };
  };
}
