{
  pkgs,
  lib,
  inputs,
}:
let
  mango = import ./mango.nix { inherit inputs pkgs; };
  shelf = pkgs.callPackage ./pluto-shelf.nix { };
  source = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../tests/capture-native.sh
      ../tests/shelf-native.sh
      ../modules/home-manager/programs/capture
      ../modules/home-manager/desktop/scripts/shelf-stop
    ];
  };
in
pkgs.writeShellApplication {
  name = "desktop-smoke";
  runtimeInputs = [
    pkgs.umbriel
    mango
    shelf
    pkgs.kitty
    pkgs.grim
    pkgs.wl-clipboard
    pkgs.imagemagick
    pkgs.jq
    pkgs.coreutils
    pkgs.dbus
    pkgs.glib
    pkgs.util-linux
    pkgs.gawk
    pkgs.wtype
  ];
  text = ''
    # The harness creates every HOME/XDG/socket itself; never reuse a host bus.
    export PLUTO_BIN=${shelf}/bin/pluto
    export PLUTO_STOP=${source}/modules/home-manager/desktop/scripts/shelf-stop
    bash ${source}/tests/capture-native.sh umbriel ${pkgs.umbriel}/bin/umbriel
    bash ${source}/tests/capture-native.sh mango ${mango}/bin/mango
  '';
}
