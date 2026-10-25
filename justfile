set positional-arguments

# Show available commands. Enter `nix develop` first to get the pinned tools.
default:
    @just --list

check:
    nix flake check --no-update-lock-file

desktop-smoke:
    nix run .#desktop-smoke

fmt:
    @sh lib/format.sh

build host:
    @sh lib/commands.sh build "$1"

build-fast host:
    @sh lib/commands.sh build-fast "$1"

diff host:
    @sh lib/commands.sh diff "$1"

apply host:
    @sh lib/commands.sh apply "$1"

update *inputs:
    nix flake update "$@"

# Preview only; never prune manually registered theme or migration roots.
clean:
    nh clean user --dry --keep 5 --keep-since 30d --no-gcroots --no-direnv

clean-apply:
    nh clean user --keep 5 --keep-since 30d --no-gcroots --no-direnv

# Requires an applied system profile providing tlpctl.
power profile:
    tlpctl set "$1"

# Requires an applied system profile providing dotfiles-boost.
boost +command:
    dotfiles-boost "$@"
