{
  config,
  lib,
  pkgs,
  ...
}:
let
  runtime = import ../../../../lib/runtime-script.nix { inherit pkgs lib; };
  dependencies =
    with pkgs;
    [
      bash
      coreutils
      jq
      grim
      slurp
      wl-clipboard
      libnotify
      imagemagick
      satty
      hyprpicker
      gnugrep
      util-linux
      systemd
      pulseaudio
      ffmpeg
      gpu-screen-recorder
      ripdrag
      xdg-utils
      xdg-user-dirs
      procps
      psmisc
      kitty
      yazi
      (tesseract.override {
        enableLanguages = [
          "eng"
          "ind"
        ];
      })
    ]
    ++ lib.optionals config.dotfiles.desktop.umbriel.enable [ pkgs.umbriel ]
    ++ lib.optionals config.dotfiles.desktop.mango.enable [
      config.wayland.windowManager.mango.package
    ];
  window = runtime {
    name = "capture-window";
    source = ./window;
    runtimeInputs = dependencies;
  };
  record = runtime {
    name = "shot-record";
    source = ./record;
    runtimeInputs = dependencies ++ [ window ];
  };
  close = runtime {
    name = "desktop-close";
    source = ./close;
    runtimeInputs = dependencies ++ [ window ];
  };
  picker = runtime {
    name = "pick-color";
    source = ./pick-color;
    runtimeInputs = dependencies;
  };
  shot = runtime {
    name = "shot";
    source = ./shot;
    runtimeInputs = dependencies ++ [
      window
      record
    ];
  };
in
{
  options.dotfiles.programs.capture.enable =
    lib.mkEnableOption "Wayland screenshots, annotation, OCR and recording";
  config = lib.mkIf config.dotfiles.programs.capture.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "Wayland capture is supported on Linux only.";
      }
    ];
    systemd.user.services.dotfiles-record = {
      Unit = {
        Description = "Desktop workflow recording";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${record}/bin/shot-record worker";
        KillSignal = "SIGINT";
        KillMode = "control-group";
        TimeoutStopSec = 30;
        Restart = "no";
        UMask = "0077";
      };
    };
    home.packages = [
      shot
      record
      close
      picker
      window
      (pkgs.writeShellScriptBin "desktop-window-info" ''
        info=$(${window}/bin/capture-window info) || exit $?
        printf '%s\n' "$info" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send 'Window info' "$info"
      '')
    ];
  };
}
