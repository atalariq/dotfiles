# Backlog

Checkmarks describe source implementation. Build evidence and pending acceptance
are recorded in [validation](docs/artifacts/validation.md).

## Current architecture

- [x] Alphabetical configured programs; package-only apps live in profiles.
- [x] Upstream Home Manager settings for structured CLI configuration.
- [x] Shared identity-free workflow profiles and explicit host registry.
- [x] flake-parts outputs for Linux x86/ARM and macOS ARM.
- [x] NixOS, Ubuntu/Home Manager, Ubuntu WSL, NixOS-WSL and Darwin examples.
- [x] Just/nh build, apply, update, cleanup preview and fast-build commands.
- [x] Direnv and three optional templates: Bun with services, Go and Rust.
- [x] Stylix targets/adapters, saved Gruvbox selection and retained variants.
- [x] Look launcher/clipboard ownership; Noctalia panel and lockscreen.
- [x] TLP/tlp-pd policy, temporary performance holds and physical Android workflow.
- [x] Selected creative/development applications and pinned pen.dev package.
- [x] Syncthing with manual pairing and localhost UI; no automatic sharing.
- [x] Disable ThinkPad SSH server; retain authentication and rollback material.
- [x] Umbriel default, Mango fallback and Noctalia Greeter declarations.
- [x] Shared capture workflow with native compositor queries and packaged tools.
- [x] Flat nvf package definition and conform startup regression check.
- [x] Annotated Nix and Indonesian maintenance handbook.

## Host acceptance

- [ ] Accept Noctalia Greeter, login Umbriel, then login Mango fallback.
- [ ] Test real screenshots, clipboard, Save, Decorate, Satty and OCR in both sessions.
- [ ] Confirm nvim from the activated PATH loads conform without startup errors.
- [ ] Review existing HOME ownership and perform the real system activation.
- [ ] Confirm Look focusing, shortcuts, clipboard and absence of old collectors.
- [ ] Verify TLP panel switching, charger events, hold release and suspend/resume.
- [ ] Measure battery/temperature, representative Android build and gaming frametime.
- [ ] Test audio USB, REAPER recording, creative applications and device pairing.
- [ ] Confirm Syncthing pairing survives restart/rebuild, and test an actual restore.
- [ ] Run native Darwin/ARM builds and runtime checks on available machines/runners.
- [ ] Provision application accounts, age identities, SDK licenses and device trust.
- [ ] Replace the screenshot placeholder with an accepted desktop capture.

## Optional future work

- [ ] Human-authored Wana Base16 scheme through the existing registry.
- [ ] Select an actual backup destination before introducing Restic scheduling.
- [ ] Revisit optional application suggestions only when a workflow needs them.

Disko, impermanence and disk migration are intentionally excluded. Mac Intel is
outside the active platform matrix because upstream Nixpkgs dropped support.
