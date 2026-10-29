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
  # Plugin helpers (Shelf's GTK4 drop window, future plugin subprocesses) run
  # as children of noctalia, so the runtime lives on the service, not the
  # profile: one aggregated lib set + one python env, extended here when a new
  # plugin needs more. pango.out is explicit: the default output's
  # girepository is empty, and PangoCairo lives in out.
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
  pythonPlugins = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);
  noctaliaWrapped =
    pkgs.runCommand "noctalia-plugin-env" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper ${cfg.package}/bin/noctalia $out/bin/noctalia \
          --set-default GI_TYPELIB_PATH ${giTypelibPath} \
          --set-default LD_LIBRARY_PATH ${giLibPath} \
          --set-default LD_PRELOAD ${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so.0 \
          --set-default SHELF_LAYER_SHELL_TRIED 1 \
          --prefix PATH : ${
            lib.makeBinPath [
              pythonPlugins
              pkgs.glib
            ]
          }
      '';
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
    # Preserve restarts when generated settings change, as well as the upstream
    # palette/root triggers. Native live edits use Noctalia's own file watcher.
    systemd.user.services.noctalia.Unit.X-Restart-Triggers = [ "${generated}" ];

    # ExecStart ships as a one-element list upstream; replace it wholesale so
    # helpers inherit GI_TYPELIB_PATH/LD_LIBRARY_PATH/LD_PRELOAD plus a PATH
    # python3 (pygobject3 + pycairo) and gdbus from the service environment.
    systemd.user.services.noctalia.Service.ExecStart = lib.mkForce [
      "${noctaliaWrapped}/bin/noctalia"
    ];

    # Packages dependencies for core function and plugins. GTK/python
    # runtimes live on the service wrapper above; only PATH-level helpers
    # that plugins shell out to stay here.
    home.packages = with pkgs; [
      xdg-utils
      wl-clipboard
    ];
  };
}
