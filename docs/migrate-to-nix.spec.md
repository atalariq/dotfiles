# Dotfiles v1: specification and CLI-agent handoff

Status: architecture approved by Ariq, 20 October 2026. This document records design decisions, not a completed implementation. No repository or target machine was inspected in this conversation. No issue tracker has been configured or updated.

## Problem statement

Ariq wants one source of truth for terminal workflows across NixOS, other Linux distributions, macOS, and WSL. Configuration must work both through automated installation and by manually copying an application's native configuration folder. Editing deployed configuration should edit the repository working tree directly. The repository is being rebuilt from scratch; importing an old dotfiles framework is not required.

## Solution

Keep native application configuration independent of Nix. Use Nix flakes to pin workflow packages, Home Manager (HM) to install the user environment and create live working-tree links, and a small config-only helper for machines without Nix. Both paths consume one mapping manifest. A shared terminal baseline can be extended or reduced per host. System configuration is an optional host capability.

Reproducibility means a known Git revision for configuration plus pinned package inputs and application plugin lockfiles. Live, uncommitted edits are intentionally outside that guarantee. Linux and macOS share workflow intent, not identical binaries or complete OS state.

## User stories

1. As the owner, I can apply packages and configuration with one entry point.
2. As the owner, I can apply configuration without Nix or package installation.
3. As the owner, I can copy one complete application configuration folder and use it without cloning the rest of the repository.
4. As the owner, I can edit deployed files and see changes in my Git working tree.
5. As the owner, I can bootstrap a previously unknown machine using a baseline without inventing a host configuration first.
6. As the owner, I can add or exclude applications per host without duplicating native configuration.
7. As the owner, I can keep local identity and preference overrides outside version control.
8. As the owner, I can inspect intended changes before applying them.
9. As the owner, I retain existing files unless I explicitly authorize backup and replacement.
10. As the owner, I can rerun apply safely and recognize already-correct links.
11. As the owner, I explicitly update pins rather than obtaining new versions as an incidental effect of apply.
12. As the owner, I approve system changes before activation.
13. As the owner, I can understand partial failure and recover without losing local edits.
14. As the owner, I can clone into any directory, including paths containing spaces.
15. As the owner, I can keep project toolchains in project-specific development shells.
16. As the owner, I can use Nix rollback for packages and Git for the contents of live config files.

## Implementation decisions

### Native configuration and local overrides

- Native Fish, Lua, TOML, and other application formats are authoritative. Do not maintain a generated second copy or encode the same application setting in both native files and HM program options.
- Each application's configuration folder is independently usable. It must not source helper files from sibling applications or a repository-global runtime directory.
- A folder may contain multiple configuration files. Manual use requires documented destination, application version requirements, external dependencies, and any first-run downloads.
- Optional local overrides use the naming convention `*.local.*`, are ignored by Git, and are loaded after shared defaults where the application supports it. Use application-specific loading, not an assumed universal include facility.
- Application plugin managers own their plugins; committed lockfiles capture plugin versions where supported. Nix owns applications and external tools. Do not install the same plugins through both mechanisms.
- Missing optional programs must not break shell startup. Do not invent personal aliases or aggressively replace standard commands without an explicit preference.
- Credentials, login tokens, histories, caches, and mutable application state are excluded from repository management.

### Links and ownership

- Link live working-tree content, not a frozen copy of configuration in the Nix store. HM may create a store intermediary, but the final target must resolve to the actual checkout.
- Default to file-level mappings. Allow directory-level mappings for config-only trees, such as Neovim when its state lives elsewhere. Mixed configuration/state directories require selective mappings.
- Do not use a flake-relative Nix path as an accidental substitute for the live checkout path. Supply the checkout location explicitly as a string through a documented host/bootstrap mechanism; do not hardcode a username or home path.
- One manifest owns application IDs and source-to-destination mappings, including file versus directory behavior. A simple JSON format is an implementation recommendation because both Nix and a small helper can read it; it is not a reason to add a framework.
- Validate source containment, target containment, duplicate/overlapping targets, missing sources, invalid app IDs, and symlinked ancestor behavior. Reject unsafe ambiguity rather than traversing an unexpected path.
- Repeated apply preserves correct links. Never silently take over unrelated files or foreign links. Backup-and-replace requires an explicit option and preserves the original object without overwriting older backups.
- HM and config-only may represent links differently. Define and test ownership recognition based on validated mappings and resolved targets. A transition must preserve foreign files and edits; do not weaken all HM collision checks to make it pass.
- If live links point inside a repo directory, locally generated overrides in that directory must still be ignored by Git. Moving the checkout requires reapply. Removing an application must not leave undocumented stale managed links; implement conservative cleanup using recorded ownership, or report the exact manual cleanup needed.

### Packages, hosts, and system integration

- Use flakes without adding a module framework unnecessarily. Keep the flake as a small composition layer and commit its lockfile.
- Pin tools that are sensitive to config, particularly the editor, and plugin inputs. Supporting utilities must meet documented compatible versions. Do not promise byte-identical builds across different OS/architectures.
- Baseline intent: Fish, Neovim, Yazi, eza, bat, zoxide, Starship, fd, and ripgrep, plus Git for repository operations. Host exceptions are supported.
- AI clients and desktop/ricing are optional future extensions. No minimal/dev/ultimate profile tiers: use baseline plus named host differences.
- Project runtimes, language servers, formatters, and build dependencies belong to project dev shells unless a specific cross-project baseline requirement is justified. Never install every language toolchain globally.
- NixOS uses HM as a system module. Hosts choosing nix-darwin may integrate similarly. Hybrid hosts use standalone HM behind the same user-facing command.
- System-manager support is a future integration to verify per distribution. Do not imply that its use makes all of AlmaLinux, Arch, Fedora, or other distributions fully Nix-managed or supported.
- Unknown hosts receive user-environment baseline only. OS detection is not consent to manage the system.
- If Nix is absent, explain and request consent before its installation. Config-only must remain available without Nix. Do not silently install Nix on managed/lab machines.
- Root privileges are reserved for necessary system operations. Never run the whole dotfiles wrapper as root just to simplify path handling.
- Preserve existing hardware, bootloader, disks, users, and state-version settings when integrating into a real NixOS host. Do not fabricate hardware configuration.

### Command contract

- Apply: packages and configuration for the selected baseline/host, using existing pins.
- Config-only apply: native symlinks without invoking Nix, package managers, downloads, or privilege escalation.
- Application selection is supported only for config-only. Reject application-scoped full apply rather than pretending a system rebuild isolates one application.
- Plan: report selected host, application mappings, conflicts, package actions, and system involvement without mutation. Distinguish a static intent preview from an exact Nix build closure diff; never imply more precision than was computed.
- Update: explicitly update Nix pins and show resulting changes. Plugin updates stay with application tooling. Update does not activate the system.
- Doctor: read-only checks for runtime prerequisites, required commands, broken/foreign links, and configuration mappings. Do not execute arbitrary application login commands or print secrets.
- Host selection can use an explicit override and a documented mapping; unknown hosts fall back to baseline. User identity and checkout location are derived or supplied, never copied from another host.
- Specify bootstrap prerequisites explicitly. A Python standard-library implementation is acceptable given the owner's experience, but Python availability must be checked and documented; config-only is Nix-free, not prerequisite-free.

### Activation and recovery

1. Preflight all selected mappings, prerequisites, and host intent.
2. Build required Nix outputs without activation.
3. Present intended system changes and request confirmation before activation. Refusal leaves the active system unchanged; downloads/build results may already exist.
4. Activate through the appropriate integration, using the built output where supported to avoid an unreviewed second evaluation.
5. Report success or partial failure with completed stages and concrete recovery instructions.

No promise of atomicity across installing Nix, activating a system, and linking files. Build failure must not activate configuration. Activation failures can be partial. Do not automatically reset Git or overwrite local configuration to simulate rollback. Nix generation rollback does not restore working-tree contents.

## Testing decisions

Use the command boundary with temporary homes and checkout fixtures as the primary test seam. Assert observable files, links, exit status, and preservation of user content, not private implementation details. Existing repository tests and conventions must be inspected by the implementing agent; none were available here.

Required acceptance checks:

1. Config-only succeeds with Nix absent from PATH and never attempts installation/network access.
2. A copied Fish configuration folder starts correctly outside the repository. Missing optional tools and local overrides do not cause startup errors.
3. Apply is idempotent. Editing a deployed mapped file changes checkout content.
4. Config-only works from an arbitrary checkout path, including spaces, and honors a supported custom config root rather than assuming one hardcoded home path.
5. Existing files, foreign symlinks, broken symlinks, and overlapping targets are handled explicitly without data loss.
6. Explicit backup-and-replace preserves the original; interrupted apply reports partial progress.
7. HM/config-only transitions recognize owned links and preserve local overrides.
8. Plan and doctor do not mutate target files. Update is separate from apply.
9. Application-scoped full apply is rejected with a useful explanation.
10. Invalid manifests and unavailable sources fail before linking starts.
11. HM build/evaluation and NixOS integration are verified where Nix is available. Do not activate the operator's real system merely to run tests.
12. Refusing system activation leaves the active system untouched. Build failure does not run activation.
13. Platform claims name exactly which OS/architecture was tested. Evaluation on Linux is not proof of macOS runtime behavior.

## Out of scope

- Native Windows; WSL is a Linux target with host-specific integration where needed.
- Desktop environments, window managers, themes, and broad ricing.
- AI-client configuration, credentials, and login automation.
- Full management of non-NixOS systems and unverified system-manager adapters.
- New package-manager abstractions, plugin frameworks, a custom Nix resolver, or generic configuration templating language.
- Publishing a repository, pushing commits, or rebuilding a real machine without the applicable authorization.

## Delivery sequence

### Slice 1: Fish end to end

Deliver one native Fish configuration folder, one application manifest entry, a minimal config-only linking path, and HM wiring that uses the same mapping. Provide the command interface needed to plan, apply config-only, and diagnose this slice. Prove manual copy and direct-edit behavior first. Avoid personal prompt/theme assumptions; optional integrations are guarded.

### Slice 2: NixOS integration

Build and review HM integrated with the actual NixOS host configuration. Add the full apply path and per-activation confirmation. Use a fixture/example module when the real host configuration is unavailable; label it as an example, not a deployable host.

### Slice 3: baseline expansion

Add the remaining baseline applications with native configuration, dependency documentation, appropriate link granularity, and application-specific local override behavior. Neovim's plugin lockfile comes from real resolution, not invented revisions.

### Slice 4: portability validation

Exercise config-only manual copy independently of Nix, then hybrid Linux and macOS user-environment paths on available target systems. Maintain explicit tested/untested status. Production non-NixOS system management remains future work.

## Repository layout and example interface

These names record the approved organization; the implementing agent may choose small internal filenames without changing the boundaries.

```text
apps/       native, independently usable configuration folders
nix/        package selection and Home Manager integration
hosts/      host-specific choices and optional system configuration
bootstrap/  thin command orchestration and config-only linking
flake.nix
flake.lock
dot
```

```sh
./dot plan
./dot apply
./dot apply --config-only
./dot apply --config-only --app fish
./dot update
./dot doctor
```

## CLI-agent prompt: implement the first slice

Copy the following prompt into the CLI agent running in the intended repository, and make this entire specification available to it.

```text
Implement the first vertical slice of the attached approved Dotfiles v1 specification: Fish native configuration, a shared mapping manifest, Nix-free config-only installation, and Home Manager wiring.

First inspect AGENTS.md, repository status, existing files, and available tools. Preserve unrelated work. This is a rebuild-from-scratch design, but that is not permission to delete existing files. If no repo exists, scaffold in the explicitly designated working directory. Do not invent access to Ariq's current machine/configuration.

Read the full spec before implementation. Its central invariant is one native configuration source used by manual copy, config-only links, and HM. Native application files must run without repository-global helpers or Nix-generated fragments. HM must link the live checkout, not accidentally freeze the config in the flake store snapshot.

Deliver only slice 1 now. Keep future system/host integration seams small; do not build every adapter or app. Use standard-library/simple tooling where practical. Document any bootstrap interpreter requirement. Choose and explain a simple shared manifest representation readable by both Nix and the helper; do not duplicate source-target mappings.

Provide functional plan, config-only apply with --app fish, and doctor for this slice. An unfinished command must fail clearly, not print a success placeholder. Reject unsupported full apply rather than activating an improvised system configuration. Provide HM build instructions and minimal integration wiring without fabricating hardware config or stateVersion values for a real host. Use clearly labeled examples when necessary.

Test behavior in disposable homes/checkouts: idempotency, arbitrary checkout path including spaces, direct editing, native-folder manual copy, missing optional tools, preserved local overrides, collision and backup behavior, invalid mappings, and plan/doctor non-mutation. Test HM/config-only ownership interoperability if Nix is available; otherwise document that gap precisely. Never claim a platform passed if it was not run there.

Do not install Nix, change login shells, alter the operator's actual dotfiles, activate a real system, push, or publish as part of implementation. Ask only if a real blocker cannot be resolved safely from the approved spec. Routine internal implementation choices are yours.

Finish with: files changed, why the boundaries were chosen, exact verification results, commands Ariq can run, known limitations, and the next smallest implementation slice. Keep the wrapper an orchestrator rather than a package manager.
```

## Reference pointers for implementation verification

- Home Manager dotfiles and live links: https://nix-community.github.io/home-manager/usage/dotfiles.html
- Home Manager NixOS integration: https://nix-community.github.io/home-manager/installation/nixos.html
- Home Manager installation modes: https://nix-community.github.io/home-manager/installation.html
- Flakes concepts and limitations: https://nix.dev/concepts/flakes
- Optional future system-manager integration: https://github.com/numtide/system-manager

The implementing agent must check the APIs/options of its pinned releases. This document specifies intended behavior; it does not claim current commands have been tested in a repository.
