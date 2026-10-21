# Dotfiles v1 vocabulary

**Native app**: the owner’s existing configuration under `config/app/<id>` or
`config/desktop/<id>`. `config/misc/scripts` supplies explicitly mapped shared helpers.
`apps/noctalia` supplies the newly introduced Noctalia v5 settings.
**Manifest**: `apps/manifest.json`, the single mapping/package-selection source.
**Baseline**: portable terminal applications, extended/excluded by host records.
**Host capability**: explicit system integration; detecting Linux/macOS/WSL does
not authorize managing that system.
**Live link**: resolves to the working checkout; Nix generation rollback does
not revert its contents.
**Apply**: preflight, build, review, explicit activation. Config-only apply skips
Nix and uses exactly the same native link ownership/validation boundary as HM.
**Plan**: read-only static intent, not an exact closure diff.

See `docs/dotfiles-v1.md` for the implementation and recovery contract.
`hosts/<name>/host.json` is the active host selection. `profiles/` retains the
original module inventory for reference. A native module mirrors HOME paths
under config/<category>/<name>. Add its explicit mappings to the manifest and
select its ID in the host record when needed.

Mango is the only ThinkPad compositor. The old setup.sh/bootstrap.sh deployer
is retired. The wana theme pipeline (`script/theme-manifest`, `theme-sync`,
`theme-switch`) and encrypted SOPS sources remain in use. Follow AGENTS.md for
theme ownership; follow docs/secrets.md for credential handling.
