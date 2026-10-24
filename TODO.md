# Backlog

One backlog for the modular dotfiles redesign. Checkmarks describe implemented
source changes, not an unobserved successful installation. Build and runtime
results belong in [the validation record](docs/artifacts/validation.md).

## Modular configuration and documentation

- [x] Separate NixOS and Home Manager catalogues; every feature defaults off.
- [x] Group native sources and runtime helpers into workflow bundles.
- [x] Make ThinkPad and portable feature selections explicit.
- [x] Introduce immutable deployment and explicit live-checkout development.
- [x] Move the host to `hosts/nixos/thinkpad-x13`; retain the old output alias.
- [x] Preserve generated hardware, device identities, authentication and stateVersion.
- [x] Explain architecture in native source and linked decision records.
- [x] Rewrite the public README and guides; include a screenshot placeholder.
- [x] Consolidate the earlier TODO lists and remove obsolete path/command guidance.
- [ ] Replace the placeholder with actual accepted desktop/editor screenshots.
- [x] Remove compatibility source links, root wrappers and the old host alias; migrate checkout-backed HOME links.

- [x] Remove the bundles/ layer and group applications by purpose.
- [x] Integrate direnv/nix-direnv and minimal standalone devShells.
- [x] Add Stylix Gruvbox dark/light variants and the requested fonts/icon/cursor.

## Desktop, shell and editors

- [x] Split Mango into native settings, bindings, rules, tags, gestures and scratchpad.
- [x] Port the reference layout to the pinned Mango syntax; retain current host geometry.
- [x] Use systemd user services for clipboard and desktop process lifetimes.
- [x] Integrate Bash login/environment with Fish interactive terminals.
- [x] Package Neovim through nvf for standalone and Home Manager use.
- [x] Retain Lua behaviour, snippets, keymaps, language tools and previews.
- [x] Supply plugins and baseline parsers through Nix; remove startup bootstraps.
- [x] Extend independent, plugin-free Vim for server editing and navigation.
- [x] Package screenshot/OCR/recording helpers with their executable dependencies.
- [ ] Verify graphical session, portals, clipboard, interactive Yazi selection and previews.
- [ ] Verify screenshot/OCR/recording, OBS, MPD and media controls after activation.
- [ ] Exercise Neovim debugging, completion, formatting and Markdown/Typst previews.
- [ ] Exercise the standalone vimrc on a representative remote server.

## Development and applications

- [x] Provide independent flake devShell templates: Android, vanilla, Bun, Node, PHP, Python, Go, Rust, C/C++, Typst and Tectonic.
- [x] Provide on-demand PostgreSQL/Redis and metrics services only in bun-with-services with pinned image digests.
- [x] Preserve volumes on stop/down; keep migrations, seed and data deletion explicit.
- [x] Record pinned tooling versions and document operation without Nix.
- [x] Keep Lerd as a separate opt-in feature, independent of project templates.
- [x] Add the Plane Cloud launcher; do not deploy a local Plane backend.
- [x] Select academic applications explicitly, with a default-off Zotero module.
- [x] Add opt-in Steam, osu!, DOOM, MCPE and GBA/PS1/SNES/PS2 emulator modules.
- [ ] Complete Lerd onboarding, normal/.test DNS checks and public mkcert CA review.
- [ ] Accept representative Web, Laravel PostgreSQL/Redis, Go, Rust and Typst projects.
- [ ] Install/choose Android SDK, accept licenses and authorize a physical device manually.
- [ ] Verify controller/audio/graphics and game assets for the selected gaming applications.

## Secrets, agents and device acceptance

- [x] Integrate sops-nix while keeping private identities outside Git.
- [x] Deliver declared application secrets through runtime wrappers, not global shell exports.
- [x] Preserve one OpenSSH agent, forwarded sockets, separate GnuPG and local signing identity.
- [x] Install pinned Hermes CLI and native configuration; keep its gateway off.
- [x] Preserve opt-in OmniRoute's immutable image and private-state guards.
- [x] Keep a single balanced power manager; avoid speculative kernel/power tweaks.
- [x] Audit backup mountpoint checks and filename-safe rename helpers.
- [x] Build the full ThinkPad system and portable generation; inspect HOME targets read-only.
- [ ] Provision/confirm age identities and exercise secret delivery/recovery without printing values.
- [ ] Enroll/verify authentication, keyring, SSH forwarding and GPG on the target device.
- [ ] Complete Hermes/provider onboarding and OmniRoute image/provider/route onboarding.
- [ ] Verify streaming, tool calls and rate-limit behaviour for explicitly configured routes.
- [ ] Measure battery, temperatures and build behaviour; verify suspend/resume, Wi-Fi and Bluetooth.
- [ ] Review HOME ownership findings, back up reviewed conflicts and approve system activation.
- [ ] Record runtime acceptance before removing rollback generations.
- [ ] Only after acceptance: review unused store paths and report disk/RAM separately before any GC.

## Owner-managed

- Zotero has a default-off module; the workstation keeps it disabled. No package
  workaround or security exception is introduced here.
- Accounts, licenses, SDK enrollment, game assets, ROM/BIOS files and credentials
  remain outside automated setup.

## Separate roadmap

- Homelab and VPS on AlmaLinux: services, deployment, Terraform and operational backups.
- Jellyfin, Nextcloud and Immich server deployments; runtime clients can be configured separately.
- Creative applications: REAPER, Kdenlive and other evaluated media tools.
- Pentesting tools and an isolated practice lab.
- Additional collaboration applications and agent workflows after requirements are defined.

The previous manifest/devenv/agent-work migration tasks referred to a
superseded implementation. This redesign does not recreate those frameworks or
inherit their historical completion claims. Their still-relevant outcomes—build
validation, HOME ownership, native tooling, secrets isolation and real host
acceptance—are represented above.
