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
  options.dotfiles.terminal.vimv.enable = lib.mkEnableOption "vimv runtime helpers";
  config = lib.mkIf config.dotfiles.terminal.vimv.enable {
    home.packages = [
      (script {
        name = "vimv";
        source = ./scripts/vimv;
        runtimeInputs = with pkgs; [
          coreutils
          vim
          findutils
          git
        ];
      })
    ];
    home.file = {
      ".local/script/vimv".source =
        pkgs.writeShellScript "compat" "#!/bin/sh\nexec ${config.home.profileDirectory}/bin/vimv \"$@\"\n";
    };
  };
}
