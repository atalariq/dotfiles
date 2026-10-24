# python

Core packages: `python3`, `uv`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

uv uses the pinned shell Python; automatic Python downloads are disabled. Create/sync the project environment explicitly.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).
