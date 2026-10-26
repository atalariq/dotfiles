# Dotfiles

NixOS, macOS, Linux, and WSL configurations with shared defaults and explicit
per-host choices. Native application configs live alongside the Nix modules
that install them.

[Hosts](#hosts) · [Setup](#setup) · [Customization](#customization) · [Development](#development)

## Features

- **Desktop:** Umbriel, a Mango fallback session, Noctalia, and the Look launcher.
- **Appearance:** Stylix themes, fonts, and application palettes.
- **Terminal:** Fish, Starship, Git, Tmux, Yazi, Vim, and Neovim configured through nvf.
- **Configuration:** Home Manager modules, immutable generations, and optional live editing of native files.
- **Secrets:** Application-scoped SOPS files with age identities provisioned separately.
- **Development:** Independent Bun, Go, and Rust flake templates; commands collected in a plain `Justfile`.
- **Coding agents:** Native account authentication for Codex, Antigravity, and Copilot;
  optional OpenCode and Hermes through a local OmniRoute gateway.

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

Each command builds one host. Builds use `--no-link` and do not activate a
configuration. On an existing managed system, inspect the system closure changes
with `just diff-thinkpad-x13` or `just diff-macpro-m4`.

After reviewing the configuration and backing up conflicting files, run the
matching `just apply-<host>` recipe on its target machine. Inspect [Justfile](Justfile)
for the underlying commands. Home Manager activation can replace managed files
and restart user services.

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

CLI tools, Kitty, and Pen come from Nix. The host also declares GUI applications
through Homebrew. Activation leaves unlisted Homebrew packages installed and does
not auto-update or upgrade them. Homebrew cask versions and application updaters
are outside the Nix lockfile.

### Linux and WSL

Install Nix in the existing distribution before applying `linux-lab` or `wsl-lab`.
User services such as sops-nix require systemd support; enable it in WSL when
using those services. The configuration does not provision Windows or a WSL distro.

## Customization

[Common defaults](modules/home-manager/common/default.nix) select the shared CLI
environment. Each host adds its own applications, system services, and displays.
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
dotfiles.deployment.liveApps = [ "espanso" "vim" "neovim" "hermes" "opencode" ];
```

This links Espanso's native files, Vim's vimrc, Neovim's Lua runtime, Hermes's
configuration, and OpenCode's `cli.json` to their source files. Restart or reload
the application after editing. OpenCode's main configuration, generated palettes,
plugin selections, and compositor settings still require rebuilding. Writable
account settings are deliberately kept separate: applications that replace their
settings files can break a symlink. Edit the checkout files rather than asking an
application to save over managed settings.

Freesm Launcher is available through `dotfiles.programs.freesmlauncher.enable` on
x86_64 Linux. Its official AppImage is pinned and wrapped for NixOS; Java 21 is
included. Select a compatible Java version for each game instance. Existing
worlds, launcher accounts, and instances are not migrated.

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

Enable tools independently with `dotfiles.programs.<name>.enable`. The desktop
hosts select Codex, Antigravity (`agy`), Copilot, and Claude Code. Gemini CLI is a
separate opt-in module. Authentication and account model selection happen in each
application; Nix never manages login tokens.

Agent CLIs and RTK come from the pinned `llm-agents` input, independently of
the system package channel. OpenCode uses its `opencode2` package and executable
for V2 configs.
Update this toolchain with `just update llm-agents`, then build and review before
activation; updates remain explicit and reproducible through `flake.lock`.

Run the native CLIs from the authorized project directory. Seed the writable
settings described below before using the bare Claude, Antigravity, or Copilot
commands.

| Command | Configuration and authentication |
| --- | --- |
| `codex --profile development` | Managed workspace profile; native OpenAI account login |
| `agy --effort high` | Native auto mode and sandbox settings; Google sign-in |
| `copilot` | Native sandbox and manual permissions; GitHub sign-in |
| `claude` | Native user settings seeded from the template; Claude authentication |
| `opencode2 --standalone` | Private server with the managed OpenCode V2 configuration |
| `hermes` | Managed Home Manager configuration through OmniRoute |

The Codex profile, Antigravity session effort, and OpenCode private-server flag
remain explicit command-line choices. No aliases or wrappers are required.
Privileged operations and activation require explicit approval. Model availability
depends on account entitlement; there is no automatic cross-agent fallback or
shared authentication store.

Copilot saves routine tool approvals per project through its native permission
prompts and `/permissions`; retain manual review for privileged or publishing
commands. Saved approvals remain application-owned. Its
[saved permissions format](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference#permissions-configjson)
does not support deny rules. To retain the explicit destructive Git and release
restrictions, run:

```sh
copilot --deny-tool 'shell(git push:*)' --deny-tool 'shell(git reset:*)' --deny-tool 'shell(git clean:*)' --deny-tool 'shell(gh release:*)'
```

The Codex development profile permits networking, including the local Nix daemon,
and writes to the Nix cache and RTK state. Other home files remain hidden outside
the workspace. External handoff access needs a separate, scoped approval. On Linux,
Claude's sandbox cannot allow just one Unix socket; Nix daemon access therefore
remains a separate permission decision instead of enabling all local sockets.

Claude, Antigravity, and Copilot keep writable native settings. Seed their templates
once after activation; the following commands refuse to overwrite existing files:

```sh
umask 077
mkdir -p ~/.claude ~/.gemini/antigravity-cli ~/.copilot
(set -C; cat "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/templates/claude.json" > ~/.claude/settings.json)
(set -C; cat "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/templates/agy.json" > ~/.gemini/antigravity-cli/settings.json)
(set -C; cat "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/templates/copilot.json" > ~/.copilot/settings.json)
```

If profiles already exist, merge the templates manually. To load the managed
Claude template without changing existing user settings, run
`claude --settings "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/templates/claude.json"`.
Keep root `AGENTS.md` as the project guidance. For a different agent, pass its path explicitly if the tool
does not discover it. Cross-tool progress belongs in a short external handoff at
`~/.local/state/dotfiles/handoff.md`: objective, changed files, verification,
unresolved findings, and next action. Start each continuation by checking the diff.

#### Privileged operations

Agents may request approval for `sudo`, `doas`, `pkexec`, and activation commands.
Approval of a command and OS authentication are separate steps. Review the complete
command before approving it; do not save a blanket approval for privilege tools.
Codex keeps its native on-request policy. Claude keeps strict sandbox retries and excludes only named privilege commands,
which have explicit ask rules. Copilot uses manual permission mode with project-scoped saved approvals
and per-command sandbox bypass available; resumed sessions retain
their previous mode, so inspect `/permissions` and `/sandbox` before proceeding.
Antigravity uses its native ask rules and sandbox review. These settings do not
provide unrestricted or passwordless root access.

On a Linux desktop with a registered polkit authentication agent, a privileged
command can request the system authentication dialog:

```sh
pkexec --disable-internal-agent /run/current-system/sw/bin/nixos-rebuild switch --flake "$PWD#thinkpad-x13"
```

Run it only after build and review. The flag prevents fallback to a textual
password prompt in the agent tool. Without a desktop agent, authenticate and run
`sudo` yourself in a local terminal; macOS and headless hosts use that path.
Never pass passwords through chat, tool input, command arguments, or an askpass
script. Hermes uses local terminal execution and can request an approved host
command; its command approvals do not provide filesystem isolation.

#### OpenCode and Hermes

OpenCode uses the V2 configuration schema. Start it in the authorized project
with `opencode2 --standalone`; the private server loads the current configuration
instead of reusing a background server. Connect the `omniroute` integration with
`/connect`, using a gateway client key, then select
`omniroute/ds/deepseek-flash` in `/models`. Thinking mode uses high effort.
`omniroute/ds/deepseek-v4-pro` is an explicit alternative for demanding tasks;
both routes use the paid DeepSeek API. Neither step limits provider spending.

Build can delegate focused searches to Explore and reviews to `reviewer`.
The reviewer cannot edit, execute shell commands, or delegate. Build and reviewer
have 40- and 12-step limits respectively; continue a session when more work is
needed. These are loop guards, not monetary limits. Ask for review when the risk
justifies it, and require the actual validation commands and results before
accepting an implementation.

Routine file edits and selected Git/Nix checks are allowed. External directories,
unlisted commands, and content searches require approval. In this OpenCode
version, `grep` checks the search expression rather than each result's read rule;
read denials therefore do not protect secrets from an approved search or shell
command. Keep plaintext credentials outside project directories, review requested
search scope, and do not use `--auto`. There is no OS sandbox for OpenCode here.

The Home Manager module `modules/home-manager/programs/hermes/default.nix` installs
the Hermes CLI and manages `~/.hermes/config.yaml`; authentication and session data
stay writable and application-owned. Hermes reads a separate gateway client key from `OPENAI_API_KEY` in its writable
`~/.hermes/.env`. Create that file locally with mode `0600`; never source it or
put the key in command arguments. Launch Hermes from an authorized project only.
Its local terminal backend uses the host tools, including Nix and `br`. It runs
with the user's filesystem access; command approvals are not an OS sandbox.
Keep credentials outside the project and review commands that access private data.

#### Local gateway

`dotfiles.programs.omniroute.enable` installs a Linux-only rootless Podman service
with a pinned image, persistent data, and a loopback-only port. After activation,
open **<http://127.0.0.1:20128/dashboard>**. Configure providers, client API keys,
and routing in the native dashboard. The API base URL is
`http://127.0.0.1:20128/v1`; `just omniroute-status` and `just omniroute-logs`
inspect the service.

Native bootstrap creates private startup keys in the gateway data directory.
Back up the entire directory, including `server.env` and the database, together.
SOPS can supply an optional startup environment instead. Upstream provider keys
and gateway client keys are separate credentials. DeepSeek routing uses its paid
official API; account caps and usage monitoring remain provider responsibilities.
The gateway is local to Linux: a Mac client needs its own reachable gateway and
`dotfiles.programs.opencode.gatewayUrl` set in its host configuration. Do not
expose the dashboard directly to a network.

Hermes runs terminals locally, without an additional container image. Background
inference schedules are disabled. OmniRoute remains a separate rootless container
service; it does not execute project development commands.

#### Shared task queue

Enable `dotfiles.programs.beads-rust.enable` to install Beads Rust (`br`). This
repository tracks portable issues in `.beads/issues.jsonl`; databases, locks, and
machine-local history remain ignored. Tasks describe their acceptance checks, and
owner-dependent tasks remain deferred until those checks can be performed.

Use the main checkout's queue for every worktree of this repository. The module
exports `DOTFILES_BEADS_DIR` without redirecting Beads in unrelated projects. For
example, substitute a unique tool/session actor and an issue ID from `ready`:

```sh
br ready --db "$DOTFILES_BEADS_DIR/beads.db" --brief --json
br show ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" --json
br update ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" --claim --actor opencode-session
br comments add ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" 'Checks run, results, unresolved findings'
# Close only after the issue acceptance criteria pass.
br close ISSUE --db "$DOTFILES_BEADS_DIR/beads.db" --reason 'Verified outcome'
br sync --db "$DOTFILES_BEADS_DIR/beads.db" --flush-only
```

Exclusive claims prevent two workers from owning the same issue. They do not lock
files; use separate worktrees and coordinate overlapping modules. Do not steal
claims or force imports. After receiving reviewed JSONL changes, run
`br sync --db "$DOTFILES_BEADS_DIR/beads.db" --import-only`.
Beads never commits or pushes changes. The owner coordinates queue commits and
reviews integration; native agent authentication remains independent.

Codex's development profile grants access only to the shared queue beneath the
otherwise hidden home directory. Claude and Copilot templates include the same
scoped directory; merge updated templates into existing writable settings.
Antigravity can add it for a worktree session with
`agy --effort high --add-dir "$DOTFILES_BEADS_DIR"`; Copilot supports
`copilot --add-dir "$DOTFILES_BEADS_DIR"`. OpenCode has scoped directory
permissions and Beads command rules; Hermes's local terminal can access the queue
without an extra MCP server. No automatic cross-tool dispatcher is installed.

Additional tools are independently opt-in under `dotfiles.programs`: `tokscale`,
`crit`, `agent-browser`, `codegraph`, `git-ai`, `git-surgeon`, `nono`, `herdr`,
`workmux`, and `orca`. Installing them does not start workers, index projects,
launch browsers, or authorize network uploads. Workmux can use the existing Tmux
installation. Orca remains an explicit trial.

Crit and git-ai provide writable configuration templates at
`~/.config/dotfiles/templates/{crit,git-ai}.json`. Before enabling git-ai hooks,
merge its template into `~/.git-ai/config.json`: local prompt storage, telemetry
and updates disabled, and an explicit `repositories` allowlist configured in the
Home Manager module. The module requires a nonempty allowlist because an empty native list permits
every repository. Transcript streaming, sweeping, and daemon-log uploads are also
disabled in the template. Crit's template disables share targets; merge it into
`~/.crit.config.json` before using review-sharing features. Neither template
overwrites an existing account configuration or installs hooks automatically.

## Development

| Location | Purpose |
| --- | --- |
| [hosts/](hosts/) | Platform, identity, application selection, and display settings |
| [modules/home-manager/](modules/home-manager/) | Shared defaults and application configuration |
| [modules/nixos/](modules/nixos/) | NixOS system integration |
| [modules/darwin/](modules/darwin/) | macOS system defaults |
| [modules/stylix/](modules/stylix/) | Theme palettes and adapters |
| [devshell/](devshell/) | Independent project templates |

Use `just fmt` to format Nix sources and `just check` to validate the flake and run
its checks for the current platform. Update dependencies deliberately with
`just update` or `just update nixpkgs`.

Nixpkgs, Home Manager, nix-darwin, and Stylix use the 26.05 release branches.
The lockfile pins exact revisions; a small explicit unstable application selection
preserves newer desktop, editor, and agent support. Release branches alone do not
replace the lockfile, and updates never select a fallback automatically.

The development shell includes `nom`, `nix-tree`, `deadnix`, and `statix`.
`just lint` reports source findings without rewriting files. Television-enabled
hosts include Nix search through `tv nix`; its indexes update independently of
the flake and are discovery aids rather than the installed package inventory.

RTK is available explicitly on desktop hosts. Prefer concise native commands
first; use RTK for repetitive output and recover original diagnostics before
debugging failures. No global rewrite hook, context proxy, or mandatory skill
framework is enabled.

The [Bun](devshell/bun-with-services/README.md), [Go](devshell/go/README.md), and
[Rust](devshell/rust/README.md) templates include their own usage instructions.
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
