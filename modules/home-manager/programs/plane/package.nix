{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "plane-desktop";
  version = "2.0.0";
  # Immutable ToDesktop build linked by https://go.plane.so/linux.
  src = fetchurl {
    url = "https://dl.todesktop.com/260130r75i625/builds/260325tah3zsnil/linux/appImage/x64";
    hash = "sha256-aduLyl2VrOOKDnjpVqo8RZtZq80n9MVygwfcOTPL92w=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm444 ${contents}/desktop.desktop $out/share/applications/plane.desktop
    substituteInPlace $out/share/applications/plane.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=plane-desktop' \
      --replace-fail 'Icon=desktop' 'Icon=plane'
    install -Dm444 ${contents}/desktop.png $out/share/icons/hicolor/1024x1024/apps/plane.png
  '';
  meta = {
    description = "Official Plane desktop client for Cloud and self-hosted workspaces";
    homepage = "https://plane.so/download";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
