{
  lib,
  appimageTools,
  fetchurl,
  jdk21,
}:
let
  pname = "freesmlauncher";
  version = "2.3.1";
  # Official release asset; digest published by FreesmTeam and checked locally.
  src = fetchurl {
    url = "https://github.com/FreesmTeam/FreesmLauncher/releases/download/${version}/FreesmLauncher-Linux-x86_64.AppImage";
    hash = "sha256-MY+at2K5x6Xx16B0OzfaB7XhqsAGAnTSbxB7Ju2aFiw=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  # Modern Minecraft uses Java 21. Additional Java versions remain an explicit
  # host choice; never migrate worlds, accounts or existing launcher instances.
  extraPkgs = _: [ jdk21 ];
  extraInstallCommands = ''
    install -Dm444 ${contents}/org.freesmlauncher.FreesmLauncher.desktop \
      "$out/share/applications/org.freesmlauncher.FreesmLauncher.desktop"
    substituteInPlace "$out/share/applications/org.freesmlauncher.FreesmLauncher.desktop" \
      --replace-fail 'Exec=freesmlauncher' "Exec=$out/bin/freesmlauncher"
    install -Dm444 ${contents}/org.freesmlauncher.FreesmLauncher.png \
      "$out/share/icons/hicolor/256x256/apps/org.freesmlauncher.FreesmLauncher.png"
  '';
  meta = {
    description = "Freesm launcher for Minecraft Java instances";
    homepage = "https://freesmlauncher.org/";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
