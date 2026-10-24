# typst

Core packages: `typst`, `newcomputermodern`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

The sample document uses New Computer Modern. Times New Roman and EB Garamond can be selected when installed on the host.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).
