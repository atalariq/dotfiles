{
  lib,
  python3Packages,
  fetchurl,
  wrapGAppsHook4,
  gobject-introspection,
  gtk4,
  gtk4-layer-shell,
  gdk-pixbuf,
}:
python3Packages.buildPythonApplication {
  pname = "pluto-shelf";
  version = "0.1.5";
  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/f0/ff/df9c75755beb4f8ae7a19be9829c42fde558324e9ba58616575baee7347e/pluto_shelf-0.1.5-py3-none-any.whl";
    hash = "sha256-1sna2drduX0lxs2yit6ATfmQnqv2oUAYTw86DSNfeXc=";
  };
  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    gdk-pixbuf
  ];
  dependencies = with python3Packages; [
    pycairo
    pygobject3
  ];
  # Upstream's ctypes lookup cannot find Nix libraries by their FHS soname.
  # Preload before Python/GTK starts, as required by gtk4-layer-shell.
  dontWrapGApps = true;
  preFixup = ''makeWrapperArgs+=( "''${gappsWrapperArgs[@]}" )'';
  makeWrapperArgs = [
    "--set"
    "PLUTO_PRELOADED"
    "1"
    "--prefix"
    "LD_PRELOAD"
    ":"
    "${lib.getLib gtk4-layer-shell}/lib/libgtk4-layer-shell.so"
  ];
  postInstall = ''
    # Installation and updates are owned by Nix. Do not expose upstream's
    # Hyprland installer or pip/uv updater as operational commands.
    substituteInPlace "$out/${python3Packages.python.sitePackages}/pluto/__init__.py" \
      --replace-fail 'args = sys.argv[1:]' 'args = sys.argv[1:]; args[:1] not in (["install"], ["update"]) or sys.exit("Managed by Nix; rebuild the configuration instead.")'
  '';
  pythonImportsCheck = [ "pluto" ];
  meta = {
    description = "Wayland drop shelf for files, folders, text, links and images";
    homepage = "https://github.com/HACKE-RC/pluto";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "pluto";
  };
}
