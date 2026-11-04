{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.gui.miro;
in
{
  options.dotfiles.programs.gui.miro = {
    enable = lib.mkEnableOption "miro PDF viewer";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.miro;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Miro is CLI-first and ships no desktop entry. Add one so it can be a
    # MIME default while keeping the package unchanged.
    xdg.dataFile."applications/miro-pdf.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=Miro
      Comment=Native PDF viewer with auto-reload
      Exec=${cfg.package}/bin/miro-pdf %F
      Icon=application-pdf
      Terminal=false
      Categories=Office;Viewer;
      MimeType=application/pdf;application/x-pdf;text/pdf;text/x-pdf;
      StartupNotify=false
    '';
  };
}
