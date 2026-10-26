{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  electron,
  systemd,
  libGL,
  libgbm,
  undmg,
  nss,
  nspr,
  alsa-lib,
  ncurses,
  asar,
}:
let
  version = "1.2.19";
  release = "https://github.com/highagency/pen-desktop-releases/releases/download/v${version}";
  sources = {
    x86_64-linux = {
      file = "Pen-${version}-linux-x64.tar.gz";
      hash = "sha256-7i1a0EQflv4MYh0bgCifVal8jjFmYJJoQDt44y52arY=";
    };
    aarch64-linux = {
      file = "Pen-${version}-linux-arm64.tar.gz";
      hash = "sha256-vYxDlZ2LmqFlj9HPxkCGYgcgxGahh1wEmN/5+ix/FBo=";
    };
    aarch64-darwin = {
      file = "Pen-${version}-mac-arm64.dmg";
      hash = "sha256-hsORHFt6GAU3NndCY422CGpLkN5r7bhOrsRVjtx5c5U=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
  linux = stdenv.hostPlatform.isLinux;
in
stdenv.mkDerivation {
  pname = "pencil-dev";
  inherit version;
  # Hashes are the official release asset digests, never a mutable 'latest' URL.
  src = fetchurl {
    url = "${release}/${source.file}";
    inherit (source) hash;
  };
  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals linux [
    asar
    autoPatchelfHook
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ undmg ];
  buildInputs = lib.optionals linux (
    (electron.buildInputs or [ ])
    ++ [
      nss
      nspr
      alsa-lib
      ncurses
      systemd
      libGL
      libgbm
      stdenv.cc.cc.lib
    ]
  );
  sourceRoot =
    if linux then
      "Pen-${version}-linux-${if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"}"
    else
      ".";
  dontConfigure = true;
  dontBuild = true;
  installPhase =
    if linux then
      ''
        runHook preInstall
        mkdir -p "$out/opt/pen" "$out/bin" "$out/share/applications"
        cp -r . "$out/opt/pen/"
        makeWrapper "$out/opt/pen/pen" "$out/bin/pencil-dev" \
          --add-flags "--ozone-platform-hint=auto"
        asar extract-file resources/app.asar out/assets/icon.png
        install -Dm644 icon.png "$out/share/icons/hicolor/512x512/apps/pencil-dev.png"
        cat > "$out/share/applications/pencil-dev.desktop" <<DESKTOP
        [Desktop Entry]
        Type=Application
        Name=Pen (Pencil.dev)
        Exec=$out/bin/pencil-dev %U
        Icon=pencil-dev
        Terminal=false
        Categories=Graphics;Development;
        MimeType=application/x-pencil;
        DESKTOP
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p "$out/Applications" "$out/bin"
        cp -R *.app "$out/Applications/"
        makeWrapper "$out/Applications/Pen.app/Contents/MacOS/Pen" "$out/bin/pencil-dev"
        runHook postInstall
      '';
  meta = {
    description = "pen.dev design canvas (formerly Pencil.dev)";
    homepage = "https://www.pen.dev";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames sources;
    mainProgram = "pencil-dev";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
