{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
}:
let
  pname = "concat";
  version = "0.2.8";
  releases = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-TmSjgmzbhr5D/IK+6wh+y4IUHqXFV/FW2FX9If+HzLE=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-kwWMCRNL6k8nTqbJV4t82mOKuB6+TbKEGwOnH0fZ54U=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
  src = fetchurl {
    url = "https://github.com/jub0t/Concat/releases/download/v${version}/Concat-${version}-${release.arch}.AppImage";
    inherit (release) hash;
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  # Use the official release bundle: compiling the generated Slint UI locally
  # consumes substantial RAM/swap. Models and user projects remain runtime state.
  extraPkgs =
    pkgs: with pkgs; [
      vulkan-loader
      libGL
      wayland
      libxkbcommon
    ];
  extraInstallCommands = ''
    install -Dm644 ${contents}/concat.desktop "$out/share/applications/concat.desktop"
    substituteInPlace "$out/share/applications/concat.desktop" \
      --replace-fail 'Exec=concat' "Exec=$out/bin/concat"
    install -Dm644 ${contents}/concat.png "$out/share/icons/hicolor/256x256/apps/concat.png"
  '';
  meta = {
    description = "Local-first video editor";
    homepage = "https://github.com/jub0t/Concat";
    license = lib.licenses.agpl3Plus;
    platforms = builtins.attrNames releases;
    mainProgram = "concat";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
