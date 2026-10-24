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
  options.dotfiles.programs.rsync.enable = lib.mkEnableOption "rsync runtime helpers";
  config = lib.mkIf config.dotfiles.programs.rsync.enable {
    home.packages = [
      (script {
        name = "rsync-backup";
        source = ./_security-scripts/rsync-backup;
        runtimeInputs = with pkgs; [
          coreutils
          util-linux
          rsync
        ];
      })
    ];
    home.file = {
      ".local/script/rsync-backup".source =
        pkgs.writeShellScript "compat" "#!/bin/sh\nexec ${config.home.profileDirectory}/bin/rsync-backup \"$@\"\n";
    };
  };
}
