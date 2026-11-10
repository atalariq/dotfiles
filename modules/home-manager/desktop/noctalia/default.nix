{
  config,
  inputs,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
let
  cfg = config.programs.noctalia;
  format = pkgs.formats.toml { };
  root =
    entry:
    cfg.settings
    // {
      include = {
        autoload = false;
        files = [ entry ];
      };
    };
  generated = format.generate "noctalia-config.toml" (
    root "${config.xdg.configHome}/noctalia/native/config.toml"
  );
  validated = pkgs.runCommand "noctalia-native-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out/native"
    cp -R ${./config}/. "$out/native/"
    cp ${format.generate "noctalia-validation.toml" (root "native/config.toml")} "$out/config.toml"
    # The file form validates one TOML document; the directory form expands
    # native includes and validates the complete effective configuration.
    ${lib.getExe cfg.package} config validate "$out"
  '';
  # Shelf's GTK4 helper owns its runtime. Noctalia itself must not inject GTK4
  # into the service: children such as Slack, Discord and other GTK3/Electron
  # apps would inherit it and abort at GTK init.
  #
  # pango.out is explicit: the default output's girepository is empty, and
  # PangoCairo lives in out.
  pluginLibs = with pkgs; [
    gtk4
    gtk4-layer-shell
    graphene
    gobject-introspection
    pango.out
    harfbuzz
    gdk-pixbuf
    cairo
  ];
  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" pluginLibs;
  giLibPath = lib.makeLibraryPath pluginLibs;
  shelfPythonEnv = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);
  # The helper re-execs itself with gtk4-layer-shell when it can find the
  # library. Give it the Nix paths once, then let its own cleanup drop
  # LD_PRELOAD before it launches anything else.
  shelfPython =
    pkgs.runCommand "noctalia-shelf-python" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper ${shelfPythonEnv}/bin/python3 $out/bin/shelf-python \
          --set-default GI_TYPELIB_PATH ${giTypelibPath} \
          --set-default LD_LIBRARY_PATH ${giLibPath} \
          --set-default LD_PRELOAD ${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so.0 \
          --set-default SHELF_ORIG_LD_PRELOAD "" \
          --set-default SHELF_LAYER_SHELL_TRIED 1
      '';
  # Pin the Shelf plugin locally so the plugin code is reproducible. Noctalia's
  # built-in local data source takes precedence over the app-managed copy.
  shelfPlugin = pkgs.stdenvNoCC.mkDerivation {
    pname = "noctalia-plugin-shelf";
    version = "1.2.3";
    src = pkgs.fetchFromGitHub {
      owner = "noctalia-dev";
      repo = "community-plugins";
      rev = "bbf33787769a5c93ba02a8d17bd5faac43c4f9ba";
      hash = "sha256-5QSlm5+mBhJO/61a19iO7ZZIG3F3g5fmXgAi33JPcpE=";
    };
    installPhase = ''
      mkdir -p $out
      cp -R shelf/. $out/
    '';
  };
in
{
  imports = [ inputs.noctalia.homeModules.default ];
  options.dotfiles.desktop.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";
  config = lib.mkIf config.dotfiles.desktop.noctalia.enable {
    assertions = [
      {
        assertion = config.dotfiles.appearance.enable;
        message = "Noctalia requires the shared appearance module.";
      }
    ];
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      checkConfig = true;
      # Keep desktop ownership/font and Stylix theme values generated. Native
      # bar/lockscreen/usability files are included first; host overrides win.
      settings.shell = {
        polkit_agent = true;
        clipboard_enabled = true;
        font_family = config.stylix.fonts.sansSerif.name;
      };
    };
    home.extraDependencies = [ validated ];
    xdg.configFile = {
      # The complete include tree is validated above, using immutable inputs.
      "noctalia/config.toml".source = lib.mkForce generated;
      # Link the pure native tree as one directory; runtime state stays outside.
      "noctalia/native".source = dotfilesLib.sourceFor "noctalia" ./config;
    };
    xdg.dataFile = {
      # Local plugins outrank the app-managed materialized copy.
      "noctalia/plugins/alok-debnath/shelf".source = shelfPlugin;
    };
    # Stable path used by plugins.toml. The symlink target changes on rebuild,
    # while the configured path stays host-independent.
    home.file.".local/bin/shelf-python".source = "${shelfPython}/bin/shelf-python";
    # Preserve restarts when generated settings change, as well as the upstream
    # palette/root triggers. Native live edits use Noctalia's own file watcher.
    systemd.user.services.noctalia.Unit.X-Restart-Triggers = [ "${generated}" ];

    # Packages dependencies for core function and plugins. Shelf's Python/GTK4
    # runtime lives in shelf-python above; gdbus is the plugin IPC helper.
    home.packages = with pkgs; [
      glib
      xdg-utils
      wl-clipboard
    ];
  };
}
