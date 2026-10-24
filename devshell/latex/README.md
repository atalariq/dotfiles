# latex

Core packages: `tectonic`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

Tectonic downloads its TeX bundle on first use. Warm its cache before offline work; the TeX bundle cache is separate from the Nix toolchain lock.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).
