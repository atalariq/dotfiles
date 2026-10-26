{ inputs, pkgs }:
# Retain the upstream pin and build graph; add press-without-repeat semantics.
inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./mango-norepeat.patch ];
})
