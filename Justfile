# Public framework. Keep the recipes small; host deployment lives in the
# private inventory repository.
export NIX_CONFIG := "accept-flake-config = true"

default:
    @just --list

fmt:
    nix fmt

lint:
    deadnix --fail flake.nix modules hosts home templates
    statix check .

check:
    nix flake check --no-update-lock-file --no-write-lock-file

guard:
    ./scripts/check-public.sh

build-home:
    nix build .#homeConfigurations."atalariq@x86_64-linux".activationPackage --no-link
