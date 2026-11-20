# Working on this repository

This is the **public framework**: reusable Home Manager modules and generic
examples. The owner's private hosts, secrets, dashboard targets, and task queue
live in a separate private repository.

Rules:

- Never add `secrets/`, `.sops.yaml`, private domains, private IPs, hostnames of
  owned hosts, or queue files. `scripts/check-public.sh` is the guard.
- Keep modules platform-neutral: generic NixOS, nix-darwin, non-NixOS Linux, and
  WSL. A literal personal path is a bug.
- The examples are `caladan` (NixOS), `ix` (Darwin), and `heighliner` (device
  label). They are examples, not the owner's machine.
- Run `just guard`, `just lint`, `just check`, and the Home Manager build before
  proposing a change. `gitleaks` runs in the pre-commit hook and CI.
- Changes to shared modules must keep the private inventory buildable; that
  repository pins this flake and updates its lock deliberately.
