{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.desktop.defaults;
  home = config.home.homeDirectory;
in
{
  options.dotfiles.desktop.defaults.enable =
    lib.mkEnableOption "desktop MIME defaults and session integration";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.kitty.enable;
        message = "The default text editor launches kitty; enable dotfiles.programs.gui.kitty.";
      }
      {
        assertion = config.dotfiles.programs.cli.neovim.enable;
        message = "The default text editor launches nvim; enable dotfiles.programs.cli.neovim.";
      }
      {
        assertion = config.programs.yazi.enable;
        message = "The terminal file chooser uses yazi; enable dotfiles.programs.cli.yazi.";
      }
      {
        assertion = config.dotfiles.programs.gui.miro.enable;
        message = "The default PDF viewer is Miro; enable dotfiles.programs.gui.miro.";
      }
      {
        assertion = config.dotfiles.programs.gui.oculante.enable;
        message = "The default image viewer is Oculante; enable dotfiles.programs.gui.oculante.";
      }
    ];

    # Exact keys take precedence over the text/* and image/* globs. Office
    # documents intentionally have no native default: use Google Docs/Office
    # 365 in the browser, or author in Typst.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "text/*" = "nvim-kitty.desktop";
        "text/html" = "brave-origin.desktop";
        "text/x-typst" = "nvim-kitty.desktop";
        "application/xhtml+xml" = "brave-origin.desktop";
        "application/json" = "nvim-kitty.desktop";
        "application/x-shellscript" = "nvim-kitty.desktop";
        "application/xml" = "nvim-kitty.desktop";
        "application/x-yaml" = "nvim-kitty.desktop";
        "application/toml" = "nvim-kitty.desktop";
        "application/x-typst" = "nvim-kitty.desktop";
        "application/pdf" = "miro-pdf.desktop";
        "application/epub+zip" = "readest.desktop";
        "application/x-mobipocket-ebook" = "readest.desktop";
        "application/vnd.amazon.ebook" = "readest.desktop";
        "application/x-fictionbook+xml" = "readest.desktop";
        "application/vnd.comicbook+zip" = "readest.desktop";
        "image/*" = "oculante.desktop";
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/gzip" = "org.gnome.FileRoller.desktop";
        "application/bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-rar" = "org.gnome.FileRoller.desktop";
        "application/vnd.rar" = "org.gnome.FileRoller.desktop";
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
        "application/x-xz" = "org.gnome.FileRoller.desktop";
        "application/zstd" = "org.gnome.FileRoller.desktop";
        "x-scheme-handler/http" = "brave-origin.desktop";
        "x-scheme-handler/https" = "brave-origin.desktop";
        "x-scheme-handler/about" = "brave-origin.desktop";
        "x-scheme-handler/unknown" = "brave-origin.desktop";
        "x-scheme-handler/terminal" = "kitty.desktop";
        "x-scheme-handler/bitwarden" = "bitwarden.desktop";
        "x-scheme-handler/discord" = "discord.desktop";
        "x-scheme-handler/slack" = "slack.desktop";
        "x-scheme-handler/obsidian" = "md.obsidian.Obsidian.desktop";
        "x-scheme-handler/zotero" = "zotero.desktop";
      };
    };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${home}/Desktop";
      documents = "${home}/Documents";
      download = "${home}/Downloads";
      music = "${home}/Music";
      pictures = "${home}/Pictures";
      publicShare = "${home}/Public";
      templates = "${home}/Templates";
      videos = "${home}/Videos";
      extraConfig.PROJECTS = "${home}/Projects";
    };

    home.sessionVariables = {
      BROWSER = "brave-origin";
      TERMINAL = "kitty";
      # Send GTK and Qt file dialogs through the portal. Qt5 keeps qt5ct for
      # theming; Qt6 falls through to xdgdesktopportal for file dialogs.
      GTK_USE_PORTAL = "1";
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct;xdgdesktopportal";
    };

    # The packaged nvim.desktop has Terminal=true. Launch it through kitty so
    # launchers that do not implement Terminal=true still get a terminal.
    xdg.dataFile."applications/nvim-kitty.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=Neovim
        Comment=Open files in Neovim inside kitty
        Exec=kitty -- nvim %F
        Icon=nvim
        Terminal=false
        Categories=Utility;TextEditor;Development;
        MimeType=text/plain;text/markdown;text/x-typst;application/json;application/x-shellscript;application/xml;application/x-yaml;application/toml;
        StartupNotify=false
      '';
    };

    # termfilechooser reads this before its default ranger config. The yazi
    # wrapper launches the configured terminal (kitty by default).
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=${home}
      open_mode=suggested
      save_mode=suggested
    '';
  };
}
