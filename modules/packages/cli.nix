# Shared CLI package floor for every host.
#
# This is the single list to edit when a CLI tool should be available on all
# managed hosts. Host-only tools belong in hosts/<platform>/<host>/apps.nix
# (`cli`), and tools that need native configuration keep their own module under
# modules/home-manager/programs/cli/.
#
# Rarely used utilities (dust, duf, hyperfine, ...) stay out of the profile;
# run them on demand with `comma` or `nix shell`.
{ pkgs, lib }:
with pkgs;
[
  # POSIX/system floor and base operations.
  coreutils
  findutils
  gnugrep
  gnused
  diffutils
  wget
  gnutar
  unzip
  zip
  less
  just
  jq
  curl
  rsync

  # Modern replacements and small file/transfer helpers.
  eza
  trash-cli
  croc

  # Documentation and spelling.
  tealdeer
  typos
]
++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
  psmisc
  xdg-utils
  libsecret
  adwaita-icon-theme
  wl-clipboard
]
++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
  pngpaste
]
