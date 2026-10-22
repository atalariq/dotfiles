# Personal Nix configuration

NixOS on `thinkpad-nixos`, plus portable Home Manager for `atalariq` on x86_64
Linux. Layout follows [psiri/nixos-config](https://github.com/psiri/nixos-config).

## Where to edit

| Location | Responsibility |
| --- | --- |
| `flake.nix` | Inputs, machine and portable Home Manager outputs |
| `hosts/thinkpad-nixos/` | Hardware, boot, identity and device settings |
| `hosts/standard.nix` | Desktop system baseline |
| `modules/` | NixOS desktop, authentication and Lerd |
| `home/default.nix` | Shared CLI/editor imports and user identity |
| `home/thinkpad.nix` | Personal desktop applications |
| `home/portable.nix` | Shared CLI/editor on another Linux machine |
| `home/<application>/default.nix` | Packages and links for one application |
| `home/<application>/config/` | Native application configuration |
| `scripts/` | Personal desktop helpers |
| `secrets/` | Existing encrypted sources and loader; keys stay outside Git |

The checkout location is set once in `flake.nix`. Home Manager links native
configuration directly to this checkout. Edit Lua/Fish/config files and reload
the application; rebuild after changing Nix packages or modules. A generation
rollback does not undo edits to these live files.

Neovim uses `vim.pack`. Nix supplies the editor, LSPs, formatters, linters and
external tools. Run `:PackInstall` and `:TSInstallBaseline` explicitly for initial
plugin/parser setup, then restart. Ordinary startup uses installed plugins and
parsers without downloading them. Tools cover Web/PHP, Android and Typst plus
Nix/Lua/Shell/Markdown/JSON/YAML/TOML. Bun, Node and PHP/Composer are global;
there is no project-environment framework.

Wana is the single palette. Noctalia writes desktop/Mango/Kitty color fragments;
other applications have ordinary static theme files next to their configuration.

## Build and switch

Use the normal user from this checkout. Nix Git flakes need new source files in
the index. Review and stage the new public sources explicitly, without committing
or staging credentials/runtime files:

```sh
git add -- flake.nix flake.lock home hosts modules scripts README.md .gitignore
nix flake lock
nix flake check
nix build .#nixosConfigurations.thinkpad-nixos.config.system.build.toplevel --no-link
nix build .#homeConfigurations.portable.activationPackage --no-link
```

Stop on any failure. Review lock changes before switching. Update an input
deliberately with `nix flake update nixpkgs`; avoid unrelated pin changes.

After reviewing HOME conflicts and backing them up outside the checkout:

```sh
sudo nixos-rebuild switch --flake .#thinkpad-nixos
```

For portable use, edit user/home/checkout paths when needed, then run
`home-manager switch --flake .#portable`.

Keep a working generation. `sudo nixos-rebuild switch --rollback` restores the
previous system generation; restore live configuration edits separately.

## First-time Lerd and Android setup

Lerd uses the community `lerd-nixos` package, following the
[upstream NixOS guide](https://lerd.sh/getting-started/nixos). NixOS owns Podman,
the `.test` DNS delegate, user linger and the port-80 permission setting.

After the system build, switch and normal internet DNS work:

```sh
lerd install --no-ipv6
lerd doctor
```

Use a release that skips imperative resolver changes on NixOS. Keep normal
internet DNS working when Lerd is stopped. Verify `.test` resolution and user
services. Trust only the generated **public** mkcert CA using
`security.pki.certificateFiles` in the Lerd module after it exists; its private
key stays in the user data directory. Project creation/migrations are explicit.

Android Studio owns the writable SDK. Select/install the SDK and accept licenses
there; no emulator, device authorization or license acceptance is automated.

## Optional applications

`home/hermes` preserves native settings without installing or enabling Hermes.
Import it explicitly if wanted. API keys and sessions stay outside the checkout.

`home/omniroute` is not imported by default. Pull the desired release with Podman,
inspect its actual repository digest, and save
`{"image":"docker.io/diegosouzapw/omniroute@sha256:<verified digest>"}` to
`~/.local/state/omniroute/image.json` in a private directory. Import the module in
`home/thinkpad.nix` and rebuild. The service uses only a pulled immutable image,
listens on `127.0.0.1:20128`, and keeps state outside Git. Onboarding and model
selection remain explicit; configure only verified free routes. OpenCode uses
its direct model by default.

## Completing the ownership cutover

The old `apps/`, `config/` and `script/` trees have been removed. Existing HOME
links may still reference those paths and need migration to the new generation.

Inspect the built Home Manager generation's `home-files` links and compare every
target with HOME. Save conflicting files and links outside Git. Split old
directory links when a new module owns individual child files, particularly
Mango and Kitty: Noctalia must retain writable theme fragment directories.
Preserve credentials and writable application state. Do not force-overwrite
foreign files or globally disable Home Manager collision checks.

Once the new generation is healthy, verify that no deployed link references the
old sources. Retire old theme-switch links and source-only mise configuration
at the same time. Remove the remaining
regular `~/.codex/AGENTS.md` and other old workflow instruction files during that
reviewed host cleanup. Preserve credentials, sessions and application state.

Verify plugin bootstrap, interactive previews, Lerd onboarding and physical
Android devices on the target host after activation.
