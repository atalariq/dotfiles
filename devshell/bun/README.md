# bun

Core packages: `bun`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

Project dependencies and build commands remain explicit.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).
