# Host composition

`thinkpad-nixos/host.json` explicitly records this machine's identity and live
checkout. Its NixOS files were copied from `/etc/nixos`; hardware configuration,
bootloader, disk definitions, users and system.stateVersion are preserved.
Change `checkout` when moving the clone. `host.local.json` overrides the host
record locally (ignored by Git). `include` and `exclude` select application IDs.

Unknown host names use standalone Home Manager with the portable baseline.
Identity and checkout come from the invoking user's environment. They never
receive NixOS, nix-darwin, system-manager or WSL system configuration implicitly.
Apple Silicon macOS, Linux and WSL use this standalone path; Intel macOS uses
config-only with the current package pin; native
Windows is not supported. WSL hardware is owned by Windows.

A new NixOS machine needs its own hardware scan and explicit module composition;
never reuse this ThinkPad's disk UUIDs. Add its composition in `flake.nix`.
