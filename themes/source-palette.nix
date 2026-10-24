# Literal roles in remaining native assets refer to this common Gruvbox fallback.
builtins.removeAttrs (import ./default.nix { }).gruvbox-dark.scheme [
  "scheme"
  "author"
]
