# Native commands; run `nix develop` for the pinned tools.
default:
    @just --list

check:
    nix flake check --no-update-lock-file --no-write-lock-file

omniroute-status:
    systemctl --user status podman-omniroute.service --no-pager

omniroute-logs:
    journalctl --user -u podman-omniroute.service -n 60 --no-pager

fmt:
    find flake.nix hosts modules devshell -type f -name '*.nix' ! -name hardware-configuration.nix ! -name per-device.nix -exec nix fmt -- {} +

update *inputs:
    nix flake update {{ inputs }}

build-thinkpad-x13:
    nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link

diff-thinkpad-x13:
    nix store diff-closures /run/current-system "$(nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link --print-out-paths)"

# Owner-reviewed activation only; this recipe is never run by an agent.
apply-thinkpad-x13:
    test -e /etc/NIXOS
    test "$(hostname)" = thinkpad-x13
    sudo nixos-rebuild switch --flake .#thinkpad-x13

build-macpro-m4:
    nix build .#darwinConfigurations.macpro-m4.system --no-link

diff-macpro-m4:
    nix store diff-closures /nix/var/nix/profiles/system "$(nix build .#darwinConfigurations.macpro-m4.system --no-link --print-out-paths)"

apply-macpro-m4:
    test "$(uname -s)" = Darwin
    test "$(id -un)" = atalariq
    sudo darwin-rebuild switch --flake .#macpro-m4

build-linux-lab:
    nix build .#homeConfigurations.linux-lab.activationPackage --no-link

apply-linux-lab:
    test "$(uname -s)" = Linux
    test "$(id -un)" = atalariq
    nix run .#home-manager -- switch --flake .#linux-lab

build-wsl-lab:
    nix build .#homeConfigurations.wsl-lab.activationPackage --no-link

apply-wsl-lab:
    test "$(uname -s)" = Linux
    test "$(id -un)" = atalariq
    nix run .#home-manager -- switch --flake .#wsl-lab

build-fast-thinkpad-x13:
    tlpctl launch --profile performance -- nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --max-jobs 1 --cores 8 --no-link

power profile:
    tlpctl set {{ quote(profile) }}

boost +command:
    tlpctl launch --profile performance -- {{ command }}
