{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.brave-origin;
in
{
  options.dotfiles.programs.gui.brave-origin = {
    enable = lib.mkEnableOption "brave-origin";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.brave-origin;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Bitwarden Desktop only looks for Brave at its hardcoded
    # `Brave-Browser` profile directory, while this host runs Brave Origin.
    home.activation.braveOriginBitwardenBridge = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        brave_dir="${config.xdg.configHome}/BraveSoftware/Brave-Origin"
        browser_dir="${config.xdg.configHome}/BraveSoftware/Brave-Browser"
        # Bitwarden only checks the Brave-Browser path and requires the
        # NativeMessagingHosts directory to exist before it copies the proxy.
        run install -d -m 0700 -- "$brave_dir" "$brave_dir/NativeMessagingHosts"
        if [[ ! -e $browser_dir || -L $browser_dir ]]; then
          run ln -sfn -- $brave_dir $browser_dir
        fi
      ''
    );
  };
}
