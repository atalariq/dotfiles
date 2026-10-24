{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.media = {
    capture.enable = lib.mkEnableOption "tools tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.media.capture.enable {
      home.packages = with pkgs; [
        gpu-screen-recorder
        ripdrag
        satty
        (tesseract.override {
          enableLanguages = [
            "eng"
            "ind"
          ];
        })
      ];
    })
  ];
}
