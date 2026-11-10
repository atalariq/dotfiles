# zaread is a small POSIX shell wrapper around zathura. It has no nixpkgs
# package, so keep the pinned upstream script here. Optional converters
# (LibreOffice, calibre, md2pdf) are deliberately not bundled; install them on
# PATH only when the owner needs those formats.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  file,
  typst,
  zathura,
}:
stdenvNoCC.mkDerivation {
  pname = "zaread";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "paoloap";
    repo = "zaread";
    rev = "035b476f8a64627f047f710bb04cadb3aa696b4d";
    hash = "sha256-Q6Fs9WNr/xm1t0rhWtxriO9ifEcUTdMCBNpgLMvJCDE=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 zaread $out/bin/zaread
    install -Dm644 zaread.desktop $out/share/applications/zaread.desktop
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/zaread \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          file
          typst
          zathura
        ]
      }
  '';

  meta = {
    description = "Lightweight document reader that opens files in zathura";
    homepage = "https://github.com/paoloap/zaread";
    license = lib.licenses.gpl3Plus;
    mainProgram = "zaread";
    platforms = lib.platforms.linux;
  };
}
