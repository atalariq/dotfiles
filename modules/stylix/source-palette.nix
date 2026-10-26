# Literal roles in remaining native assets refer to this common Gruvbox fallback.
builtins.removeAttrs (import ./schemes.nix { }).gruvbox-dark.scheme [
  "scheme"
  "author"
]
