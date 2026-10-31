# Development workflow

The toolchain has two layers. Nix provides the global fallback; mise provides
each project's pinned runtimes and task runner. Containers cover services and
runtime stacks that should not live on the host.

## Layer 1: Nix fallback

`hosts/nixos/thinkpad-x13/home.nix` and `hosts/darwin/macpro-m4/home.nix` enable
the `dotfiles.dev.stacks` toolchain (Node, Bun, Python, Go, Rust, C/C++, and
similar) through native Nix packages. These are the tools available in any
directory that does not declare its own environment.

Enable the development-tools modules on a host with:

```nix
dotfiles.programs.development.devenv.enable = true;
dotfiles.programs.development.direnv.enable = true;
dotfiles.programs.development.podman.enable = true;
dotfiles.programs.development.mise.enable = true;
```

The NixOS side also needs rootless Podman:

```nix
dotfiles.development.podman.enable = true;
```

## Layer 2: mise per project

A project that needs reproducible runtime versions commits a `mise.toml` and
lets mise install them on `cd`:

```toml
[tools]
node = "22"
python = "3.12"

[tasks]
test = "npm test"
```

```sh
mise install
mise run test
```

mise stores downloads and installed toolchains under `~/.local/share/mise`. The
Nix layer does not pin global mise tools: projects own their versions. No
`MISE_DATA_DIR` override is needed or supported.

## Choose one environment hook per project

A project uses **either** `mise.toml` (team contract, no `.envrc` required,
because mise activation reads it on directory change) **or** an `.envrc` with
`use flake` (personal Nix shells). Never both in the same repository: direnv and
mise both hook working-directory changes, and double activation causes PATH
churn.

Editor-only languages are deliberately **not** part of the Nix fallback layer:
Neovim (nvf) bundles LSP servers and formatters for languages such as PHP, SQL
and Vue inside the editor wrapper, so editing them requires no global runtime —
the runtime itself comes from the project's container (docker compose) or mise.

### Nix per project through mise

The [mise-nix](https://github.com/jbadeau/mise-nix) plugin lets mise read a
project's `flake.nix` and activate its devShell on `cd` — the mise-side twin of
`use flake` for repos that opt into Nix while keeping the team contract
mise-first. Install it at runtime (it is state, not config):

```sh
mise plugins install mise-nix
```

Whatever that nix-evals live pulls from the binary caches declared in
`modules/nix-cache.nix` (`cache.nixos.org`, `nix-community.cachix.org`, and the
desktop-specific ones), so first-run builds mostly download instead of compile.

## Containers

Rootless Podman is the container runtime. The system module enables
`dockerCompat` and the Podman Docker socket, so Docker CLI commands work without
a root Docker daemon:

```sh
docker compose up -d
docker compose ps
```

`podman-compose` and the Docker Compose v2 plugin come from the system profile;
`dive`, `hadolint`, `lazydocker`, `devcontainer`, and `yq` are in the Home
Manager podman bundle.

### Multi-architecture builds

ThinkPad hosts enable `dotfiles.development.emulation.enable`, which registers
`aarch64-linux` through QEMU binfmt. Build for both targets with:

```sh
podman build --platform linux/amd64,linux/arm64 -t image .
```

The VPS is aarch64 AlmaLinux, so arm64 images must build and run there.

### Devcontainers

`devcontainer` is available from the terminal:

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

Devcontainers are optional; they are mainly useful on lab PCs.

## Teammates without Nix

Windows teammates need only Docker Desktop and mise:

1. Install Docker Desktop and start it.
2. Install mise and run `mise install` in the project.
3. Run services with `docker compose up -d` and tasks with `mise run <task>`.

No Nix installation, WSL flake setup, or host toolchain is required for this
path. Nix users get the same commands on top of the fallback layer.

## Rules

- Commit `mise.toml` (or a lockfile, where the ecosystem has one); keep secrets
  and local state out of Git.
- Never require Nix to build or run a team project.
- Do not add a root Docker daemon; use rootless Podman with `dockerCompat`.
- Docker Compose files (`compose.yaml`) own services; `mise.toml` owns runtimes
  and single-line cross-platform tasks.
