{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.zotero;
in
{
  options.dotfiles.programs.gui.zotero = {
    enable = lib.mkEnableOption "Zotero";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zotero;
    };
    headless = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run a headless Zotero instance for the browser connector.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Zotero's GUI and headless connector service share one profile and
    # cannot run at the same time. The desktop entry goes through this
    # wrapper: stop the service, run the GUI, then restore the service.
    home.file.".local/bin/zotero-gui" = lib.mkIf cfg.headless {
      source = pkgs.writeShellScript "zotero-gui" ''
        cleanup() {
          systemctl --user start zotero.service >/dev/null 2>&1 || true
        }
        trap cleanup EXIT

        systemctl --user stop zotero.service >/dev/null 2>&1 || true
        ${cfg.package}/bin/zotero "$@"
      '';
    };

    xdg.dataFile."applications/zotero.desktop" = lib.mkIf cfg.headless {
      text = ''
        [Desktop Entry]
        Type=Application
        Version=1.5
        Name=Zotero
        GenericName=Reference Manager
        Comment=Collect, organize, cite, and share research
        Exec=${config.home.homeDirectory}/.local/bin/zotero-gui -url %U
        Icon=zotero
        Terminal=false
        Categories=Office;Literature;
        MimeType=x-scheme-handler/zotero;
        StartupNotify=false
        StartupWMClass=Zotero
      '';
    };

    systemd.user.services.zotero = lib.mkIf cfg.headless {
      Unit = {
        Description = "Headless Zotero instance";
        Documentation = [ "https://www.zotero.org/support/" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/zotero --headless";
        Environment = [ "MOZ_HEADLESS=1" ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
