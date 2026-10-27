{ inputs, pkgs }:
# Upstream package as pinned; no local patches.
inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango
