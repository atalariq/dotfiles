# Dotfiles

NixOS, macOS, Linux, and WSL configurations with shared defaults and explicit
per-host choices. Native application configs live alongside the Nix modules
that install them.

[Hosts](#hosts) · [Setup](#setup) · [Customization](#customization) · [Development](#development)

## Features

- **Desktop:** Umbriel with Noctalia for the launcher, clipboard,
  screenshots, and bar.
- **Appearance:** Stylix themes, fonts, and application palettes.
- **Terminal:** Fish, Starship, Git, Tmux, Yazi, Vim, and Neovim configured through nvf.
- **Configuration:** Home Manager modules, immutable generations, and optional live editing of native files.
- **Secrets:** Application-scoped SOPS files with age identities provisioned separately.
- **Development:** Commands collected in a plain `Justfile`; project environments come from devenv/flox rather than flake templates.
- **Coding agents:** Native account authentication for Codex, Antigravity, and Copilot;
  direct DeepSeek/OpenRouter connections for OpenCode and Hermes.

## Hosts

| Configuration | Platform | Manages |
| --- | --- | --- |
| `thinkpad-x13` | NixOS · x86_64 | System and Home Manager; Wayland desktop |
| `macpro-m4` | macOS · Apple Silicon | nix-darwin and Home Manager |
| `linux-lab` | Linux · x86_64 | Standalone Home Manager; command-line environment |
| `wsl-lab` | Ubuntu WSL2 · x86_64 | Standalone Home Manager; command-line environment |

The Linux and WSL lab configurations manage the user environment, not the host OS.
Darwin builds require a Mac or a Darwin builder.

## Setup

Install Nix with `nix-command` and `flakes` enabled, then clone this repository.
Adapt the username, home directory, Git identity, and host settings before use.
For NixOS, provide hardware and filesystem settings for the target machine.
New source files must be added to Git before they are included in a Git flake.

Enter the development shell and inspect the available commands:

```sh
nix develop
just --list
just check
```

Build the configuration for the target machine:

```sh
just build-thinkpad-x13
just build-macpro-m4
just build-linux-lab
just build-wsl-lab
```

Each command builds one host through `nh`. Builds do not activate a
configuration. On an existing managed system, inspect the system closure changes
with `just diff-thinkpad-x13` or `just diff-macpro-m4`.

After reviewing the configuration and backing up conflicting files, run the
matching `just apply-<host>` recipe on its target machine, or
`just boot-thinkpad-x13` to make the new generation the boot default and leave
the running system untouched. Inspect [Justfile](Justfile) for the native
command behind each recipe. Home Manager activation can replace managed files
and restart user services.

Generation cleanup and store maintenance are grouped at the end of the Justfile:
`just gc` keeps 14 days and the newest five generations, `just gc-all` removes
every old generation, and `just optimise` hard-links duplicate store paths.

### Binary caches

The Noctalia, Umbriel and numtide caches are declared once in
[modules/nix-cache.nix](modules/nix-cache.nix) and imported by both the NixOS and
nix-darwin modules, so `/etc/nix/nix.conf` is regenerated from the same list.
`trusted-users` is platform-specific and stays in each platform module.

Standalone Home Manager hosts (`linux-lab`, `wsl-lab`) have no system module, so
nothing in this repository writes their `/etc/nix/nix.conf`. Add the cache once by
hand on those machines, otherwise the first build compiles everything:

```nix
# /etc/nix/nix.conf
trusted-users = atalariq
extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
```

The flake deliberately has no `nixConfig`: Nix refuses to import into it (it must
be a literal attrset) and ignores the settings for untrusted users anyway.

### macOS bootstrap

Install Homebrew at its Apple Silicon prefix, `/opt/homebrew`, before activation.
For the first nix-darwin activation:

```sh
nix build .#darwinConfigurations.macpro-m4.system --no-link
sudo nix run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake .#macpro-m4
```

Subsequent activations can use `just apply-macpro-m4`. If the Nix daemon is managed
by a separate installer, set `nix.enable = false` in the host configuration before
activation. Home Manager uses its built-in application integration; macOS may
request App Management permission for the terminal.

CLI tools and Kitty come from Nix. The host also declares GUI applications
through Homebrew. Activation leaves unlisted Homebrew packages installed and does
not auto-update or upgrade them. Homebrew cask versions and application updaters
are outside the Nix lockfile.

### Linux and WSL

Install Nix in the existing distribution before applying `linux-lab` or `wsl-lab`.
User services such as sops-nix require systemd support; enable it in WSL when
using those services. The configuration does not provision Windows or a WSL distro.

## Customization

The shared environment lives under `modules/home-manager/programs/`. The `shell`,
`core`, `nix`, `git`, `tmux` and `vim` modules are enabled by default
(the "sunnah muakkad" set, overridable); everything else — `terminal`, `gui`,
`agentic-tools`, the `development.*` bundles (`android`, `devenv`, `direnv`,
`godot`, `jetbrains`, `mise`, `podman`) plus `dotfiles.dev.stacks` and
individual applications — is opt-in. Gaming is a NixOS feature
(`dotfiles.gaming.enable`), not a Home Manager package bundle. Each host adds
its own applications, system services, and displays.
Most application modules are opt-in; package definitions stay next to their consumers.

Override shared scalar defaults in the host's Home Manager module:

```nix
programs.fish.enable = false;
programs.git.settings.user.email = "you@example.com";
home.packages = [ pkgs.wget ]; # Adds to the shared package list.
# home.packages = lib.mkForce [ pkgs.git ]; # Replaces the entire package list.
```

Include `pkgs` and `lib` in the module arguments when using them. Keep each host's
`stateVersion` independent of package updates.

### Themes and native files

Select a theme with `dotfiles.appearance.theme` and rebuild. The default deployment
uses immutable sources. To edit supported native files directly, add this to a
Home Manager module with `config` in its arguments:

```nix
dotfiles.deployment = {
  mode = "live";
  checkout = "${config.home.homeDirectory}/.dotfiles";
  allowThemedFiles = true;
};
```

Set `checkout` to the actual repository location. Packages, plugins, and generated
theme files still require a rebuild. `allowThemedFiles` explicitly accepts that
limitation when live mode and appearance are enabled together.

Select individual applications instead when only some files need live editing:

```nix
dotfiles.deployment.liveApps = [ "espanso" "vim" "neovim" "fish" "umbriel" "noctalia" ];
```

This links Espanso's native files, Vim's vimrc, Neovim's Lua runtime, Fish
customization, and the native desktop fragments to their source files. Restart
or reload the application after editing. Generated palettes, plugin selections,
and host-specific desktop fragments still require rebuilding.

OpenCode and Hermes rewrite their native profiles, so those files stay writable
and application-owned. Home Manager supplies seeds under `dotfiles/templates`,
not runtime symlinks that a native command can replace. This repo's
`.opencode/opencode.jsonc` links the canonical native policy without overriding
the global provider/model selection. Hermes uses its writable native YAML.
Older `liveApps` selections for these two tools remain accepted and warn that
they do not synchronize the working profile. Generated seeds still rebuild.

Fish's native customization file is `fish/conf.d/99-dotfiles.fish` under the XDG
config directory. It runs before the generated `config.fish`; Home Manager shell
integrations and Stylix still rebuild. Validate edits with
`fish --no-config --no-execute <file>`, then reload with `source <file>` inside
Fish or start a new shell. Invalid Fish commands report errors; a failed reload
can leave earlier commands applied, so validate first. Removing commands from the
file does not undo their effects in an existing shell. Start a new shell after
switching back to immutable mode; history and universal variables stay writable.

Reload Vim edits with `:source ~/.vimrc` or start a new Vim process. A failed
`:source` reports native errors and may leave earlier settings applied. Validate
in a separate Vim process before reloading your working session. Switching back
to immutable mode requires a Home Manager rebuild; it leaves undo files intact.

Umbriel and Noctalia use native include files with explicit load order.
Edit behavior and bindings in their colocated `config/` directories under
`modules/home-manager/desktop/`. Nix still generates host displays, conditional
integrations, and Stylix colors. Immutable mode uses the same native source
snapshot; live mode uses Home Manager's `mkOutOfStoreSymlink`. Writable Noctalia
settings remain application-owned. Native validators check a complete immutable
copy of the include tree during builds, even when the deployed links are live.

Neovim is assembled from nvf and split by how often things change. Build-time
configuration - plugins, LSP servers, formatters, parsers - lives in
`modules/home-manager/programs/neovim/nvf.nix` and is shared by the Home Manager
module and the standalone `nix run .#neovim` package. The Lua runtime that stays
live is `modules/home-manager/programs/neovim/runtime/`: with Neovim selected in
`liveApps`, edit that checkout directly and restart Neovim for a reliable full
reload, since Lua `require` caches modules within a running process. Markdown is
read raw by default; `<leader>mr` toggles rendering and `<leader>mR` opens a
rendered split. Plugins, parsers and external language tools still rebuild
through a generation.

Freesm Launcher ships inside the NixOS gaming module
(`dotfiles.gaming.enable`) on x86_64 Linux. Its official AppImage is
pinned and wrapped for NixOS; Java 21 is included. Select a compatible Java
version for each game instance. Existing worlds, launcher accounts, and
instances are not migrated.

### Secrets

Configure recipients in [.sops.yaml](.sops.yaml) and supply encrypted files using
[the secrets module](modules/home-manager/services/secrets.nix). Keep private age
identities outside the checkout and Nix store. The default identity location is
`~/.config/sops/age/keys.txt`; restrict the directory to `0700` and the file to `0600`.
Use separate device identities and retain a tested recovery recipient.

Select actual encrypted files before enabling secrets. Credentials are decrypted
at runtime rather than interpolated into Nix expressions. Treat dotenv files as
data, not executable shell. Application login state and private SSH/GPG keys remain
outside the repository.

### Coding agents

Enable the integrated bundle in a host's Home Manager configuration:

```nix
dotfiles.ai.enable = true;
# Individual tools remain overridable, for example:
dotfiles.programs.hermes.enable = false;
```

The bundle selects Codex, Claude Code, OpenCode, Hermes, Beads Rust, CodeGraph,
RTK, and Tokscale. It does not start workers, index projects, install shell
rewrite hooks, or purchase provider access. Antigravity, Copilot, and
other experiments remain independently opt-in with
`dotfiles.programs.<name>.enable`. The desktop hosts explicitly select
Antigravity and Copilot for optional use.

Agent packages come from the pinned `llm-agents` input. Update them deliberately
with `just update llm-agents`, then build and review before activation. OpenCode
V2 uses the `opencode2` executable.

Home Manager activation creates **absent** native profiles from the managed
seeds with private file permissions. These are writable copies, so native
commands can save preferences. Rebuilds preserve existing files, symlinks,
authentication, sessions, models, and UI settings. Updated seeds are available
under `~/.config/dotfiles/templates`; an existing profile needs a selective
reviewed migration to adopt changed settings. No credential enters the Nix store.

Seeds stay deliberately small: shared defaults only (direct DeepSeek for
OpenCode and Hermes, schema references, update checks off, co-author opt-outs,
CodeGraph as the single MCP server). Permissions, sandbox paths, approval
lists, extra MCP servers and UI preferences are owned by each tool, which
rewrites its own profile on normal use. Add capability through the native
commands (`codex mcp add`, `claude mcp add`, `agy mcp add`,
`opencode mcp add --global`) instead of growing the Nix seed.

Agent CLIs and supporting helpers live together under
`modules/home-manager/programs/agentic-tools/`; the parent declares its imports
explicitly and the top-level program index only sees the single directory.

| Command | First-use authentication and role |
| --- | --- |
| `codex` | Native account/API setup; trusted project implementation and review |
| `claude` | Native authentication; trusted project implementation and review |
| `opencode2` | `/connect` to DeepSeek, then select the direct model; draft implementation |
| `hermes` | Native provider setup or private `DEEPSEEK_API_KEY`; optional parallel coordinator |
| `agy --effort high` | Google sign-in; draft implementation |

DeepSeek is the fresh-profile default for OpenCode and Hermes. OpenRouter is an
explicit alternative selected through the native provider settings. There is no
configured automatic paid provider fallback. Provider balances, billing fees,
and usage caps remain separate; a local configuration cannot impose one shared
spending cap across independent accounts. Subscription providers remain optional.

Run the tools in the assigned project or worktree. Routine edits and validation
use native permission and sandbox facilities. Privilege, activation, publishing,
and destructive operations retain separate review. OpenCode and local Hermes
execution are not OS filesystem sandboxes. Existing running servers and sessions
retain their settings until reloaded; `opencode2 --standalone` creates an isolated
server without restarting the shared one.

Every client keeps its own approval, sandbox and permission model. The
repository no longer ships permission lists, path allowlists or execpolicy
rules, so the first run behaves like the tool's documented default. Claude's
Linux sandbox can still need a native approval for the Nix daemon socket;
Copilot keeps its saved project approvals; Hermes applies its own defaults
because its pinned version has no arbitrary interactive ask list.

#### Integration and coordination

The helper bundle installs CodeGraph, agent-browser, crit, RTK, tirith,
Tokscale and workmux. Fresh profiles seed two MCP servers: CodeGraph and
agent-browser (`agent-browser mcp`). Stable executable names survive package
upgrades; existing profiles keep their own server lists until you update them.

Wiring stays native and reversible:

```sh
crit install claude-code   # also: codex, opencode, github-copilot, hermes
agent-browser mcp          # stdio server already seeded for the enabled clients
rtk git status             # compact output for noisy commands
tokscale clients           # where usage comes from; then `tokscale models`
workmux add <name>         # worktree + tmux window per parallel task
```

Per-agent crit setup is runtime state (not Nix-declared); the manual steps,
install order, and known `crit check` noise are documented in
[docs/agent-setup.md](docs/agent-setup.md).

Project indexing is a separate explicit action; use the CLI when a client has
not loaded its MCP server. [Tokscale](modules/home-manager/programs/agentic-tools/tokscale/README.md)
runs on demand and unpriced models can appear with zero cost, which must be
treated as unknown. None of these tools starts a background collector or
intercepts all shell commands.

Use a single agent by default. For independent parallel tasks, follow the
[native workflow](docs/agent-workflow.md): shared Beads claims, separate worktrees,
explicit write scopes, bounded worker processes, and review before integration.
Hermes is optional and admits at most two external workers. Parallel workers
consume their providers' quotas; they do not multiply an account's allowance.

Beads Rust (`br`, not `bd`) owns task status. Every worktree uses the main
checkout's `.beads` store through per-command `--db` or `BEADS_DIR`.
`DOTFILES_BEADS_DIR` points to it without redirecting unrelated projects.
Beads Viewer (`bv`) reads the same `.beads` store for a graph-aware TUI; it is a
viewer, so keep `br` as the only writer.

```sh
br coordination status --db "$DOTFILES_BEADS_DIR/beads.db" --json
br ready --db "$DOTFILES_BEADS_DIR/beads.db" --brief --json
br show ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" --json
br update ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" --claim --actor tool-session
br comments add ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" 'Checks, results, next action'
br sync --db "$DOTFILES_BEADS_DIR/beads.db" --flush-only
```

Claims reserve issues, not files. The coordinator prevents overlapping write
scopes. Task handoffs belong in issue comments; detailed local receipts live in
the main checkout's ignored `.beads/artifacts/ISSUE/SESSION/`. Historical external
checkpoints remain archives. Only the owner coordinates shared queue commits.

#### Privileged operations

Build and review first. The owner authorizes activation and authenticates using
the normal OS mechanism. On a Linux desktop with an authentication agent, a
reviewed command can use:

```sh
pkexec --disable-internal-agent /run/current-system/sw/bin/nixos-rebuild switch --flake "$PWD#thinkpad-x13"
```

Without that desktop agent, the owner runs the command in their terminal. Never
pass passwords through chat, agent stdin, command arguments, or askpass helpers.

#### Optional experiments

Tools such as Tirith, Crit, agent-browser, git-ai, and Workmux
remain optional. Installing a package alone does not prove agent
integration. Enable an integration after its intended workflow has been verified.
For git-ai, configure a nonempty repository allowlist and review its private
configuration before enabling hooks; retain the module's upload restrictions.

## Development

| Location | Purpose |
| --- | --- |
| [hosts/](hosts/) | Platform, identity, application selection, and display settings |
| [modules/home-manager/](modules/home-manager/) | Shared defaults and application configuration |
| [modules/nixos/](modules/nixos/) | NixOS system integration |
| [modules/darwin/](modules/darwin/) | macOS system defaults |
| [modules/stylix/](modules/stylix/) | Theme palettes and adapters |

Use `just fmt` to format Nix sources and `just check` to validate the flake and run
its checks for the current platform. Update dependencies deliberately with
`just update` or `just update nixpkgs`.

Nixpkgs follows `nixos-unstable`; Home Manager, nix-darwin, and Stylix follow
their master branches because no 26.11 release branch exists yet - switch them
back to `release-26.11` and `nix-darwin-26.11` when those appear. The lockfile
pins exact revisions, and updates never select a fallback automatically.

The development shell includes `nh`, `nix-tree`, `deadnix`, and `statix`.
`just lint` reports source findings without rewriting files. Television-enabled
hosts include Nix search through `tv nix`; its indexes update independently of
the flake and are discovery aids rather than the installed package inventory.

RTK is available explicitly on desktop hosts. Prefer concise native commands
first; use RTK for repetitive output and recover original diagnostics before
debugging failures. No global rewrite hook, context proxy, or mandatory skill
framework is enabled.

Application-specific behavior is documented in the relevant module and native config.

## AI Usage Disclosure

Parts of this configuration and its documentation were developed with AI assistance,
including planning, implementation, and review. Design decisions and responsibility
for the published configuration remain with the maintainer. Successful builds and
automated checks do not imply activation or testing on physical hardware.

## Credits

Built with [Home Manager](https://github.com/nix-community/home-manager),
[nix-darwin](https://github.com/nix-darwin/nix-darwin),
[Stylix](https://github.com/nix-community/stylix),
[nvf](https://github.com/NotAShelf/nvf), and
[sops-nix](https://github.com/Mic92/sops-nix).

## License

[MIT](LICENSE)
