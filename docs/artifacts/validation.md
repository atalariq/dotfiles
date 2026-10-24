# Redesign validation — 2026-10-24

Source and build verification is separate from acceptance in the real desktop.
No real system or Home Manager profile was activated.

## Ownership and cleanup

- Starting revision: `ed5c3248f91b8fe2325d6b854a3ac6e7c7363df9`.
- Existing input graphs were preserved when adding inputs; hardware and device
  configuration were compared byte for byte against the pre-cleanup snapshot.
- Personal Codex settings remain in the working tree, separate from the commit.
- Removed root `home/`, `scripts/`, old host aliases, compatibility modules and
  intermediate bundles. Canonical modules now use eleven functional groups.
- Migrated 54 checkout-backed HOME links to canonical sources. Removed only known
  obsolete source-owned leaves and repaired theme includes. No profile switch
  was needed for this source-link migration.
- Private rollback material is retained at
  `~/.local/state/dotfiles-cleanup-20261024-173644/`, including source archive,
  original patch, link inventory and replaced-path backups. Its registered
  `prepared-generation` GC root retains the generation used by repaired theme
  links. No store collection was performed.

## Completed verification

- Nine flake checks cover inert defaults, independent system features, source
  modes, direnv gating, theme switching, runtime helpers, shell syntax, Neovim
  startup and standalone Vim.
- Combined system and portable build passed (exit 0):
  `nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel .#homeConfigurations.portable.activationPackage --no-link`.
- System: `/nix/store/f3rcfsgq5pynv1b293fky4nv5abpn04p-nixos-system-thinkpad-x13-26.11.20261020.02c087f`.
- Portable: `/nix/store/6ax0rkpg500lyckdb4alf0gbvgh4rdz4-home-manager-generation`.
- Both generated Mango palettes passed parser validation. Validation reads the
  rendered fragment and checks diagnostics as well as exit status.
- All twelve devShells built; their derivations evaluated for both x86_64-linux
  and aarch64-linux. Eleven toolchain smoke tests passed, including compilation
  and a Typst PDF. These are local smoke tests, not cross-platform runtime tests.
- The LaTeX toolchain built, but Tectonic's first document compilation was blocked
  by HTTP 429 fetching the external bundle index at
  `https://data1.fullyjustified.net/tlextras-2022.0r0.tar.index.gz`.
  That document-compilation smoke test remains incomplete.
- Real Bash and Fish direnv tests passed: explicit trust, flake loading, cached
  re-entry and unloading. No project is trusted automatically.
- Rootless Podman tests passed for PostgreSQL, Redis and observability. Database
  records, Grafana configuration and a metric survived down/up. OTLP ingestion
  reached Prometheus and Grafana. Only test-owned containers and volumes were
  removed afterward. Default Grafana port is 3001, leaving 3000 free for Bun.
- Isolated temporary-HOME activation exercised dark/light switching, saved
  selection restoration, invalid-selection fallback and registered GC-root
  reachability of both variants. It did not activate the owner's profile.
- Specification and standards reviews reported no remaining concrete findings.

## Pending host acceptance

- Review real HOME ownership before activation, particularly `.bashrc` and the
  canonical-source directory link `.config/mango/script`. Build success does not
  certify a conflict-free real activation.
- A real system switch, desktop palette/reload observation, authentication,
  portals, keyring, SSH/GPG, suspend/power and physical-device testing remain
  owner acceptance work. Preserve rollback material until accepted.
- Application credentials, service/provider onboarding and a real backup/restore
  exercise remain separate from source verification.

Zotero is available as its own module with `enable = false` by default and is
also disabled in the ThinkPad selection.
