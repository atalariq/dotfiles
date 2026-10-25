{ pkgs, lib }:
let
  runtime = import ../lib/runtime-script.nix { inherit pkgs lib; };
  audit = runtime {
    name = "dotfiles-audit-home";
    source = ../lib/audit-home.sh;
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
    ];
  };
in
runtime {
  name = "dotfiles-cutover";
  source = ../lib/cutover.sh;
  runtimeInputs = [
    audit
    pkgs.coreutils
    pkgs.findutils
    pkgs.jq
    pkgs.nix
    pkgs.gnutar
    pkgs.util-linux
  ];
}
