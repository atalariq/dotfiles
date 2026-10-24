# Project environments

Templates live in `devshell/`; the public Nix flake output remains `templates`.
Each template is a standalone flake with its own lock and requires no parent
checkout after copying.

```sh
nix flake init -t /path/to/dotfiles#python
nix develop
# Or, after reviewing .envrc:
direnv allow
```

The Home Manager `dotfiles.terminal.direnv.enable` feature supplies direnv,
nix-direnv and one hook for each selected shell. `.envrc` contains `use flake`.
Once allowed, entering a project loads the cached environment; leaving unloads
it. A changed `.envrc` requires approval again. Nothing auto-installs project
dependencies, exports service secrets or starts containers.

## Minimal toolchains

| Template | Core tools |
| --- | --- |
| `vanilla` | miniserve for static HTML/CSS/JavaScript |
| `bun` | Bun |
| `node` | Node.js with npm |
| `php` | PHP and Composer |
| `python` | Python and uv; uv's Python downloads disabled |
| `go` | Go |
| `rust` | Rust and Cargo |
| `cpp` | GCC and GDB for C/C++ competitive programming |
| `android` | JDK and adb; project Gradle wrapper and writable SDK remain separate |
| `typst` | Typst and New Computer Modern |
| `latex` | Tectonic |
| `bun-with-services` | Bun, Podman and Podman Compose |

There is no combined `web` or Flutter template. Language servers, extra
formatters and container requirements are omitted from ordinary templates.
Inspect each template's `VERSIONS.md` for tool versions from its locked Nixpkgs.
Without Nix, install those tool versions manually; service Compose files remain
usable with Podman.

Tectonic fetches its TeX bundle on first use. Its download cache is separate from
the Nix flake lock: compile once while online before relying on offline builds.
Typst's sample explicitly selects New Computer Modern. Times New Roman and
EB Garamond are installed on the workstation for assignments that require them.

## Optional services

Only `bun-with-services` includes service definitions. It has independent
`postgres`, `redis` and `observability` profiles; the latter contains an
OpenTelemetry Collector, Prometheus and Grafana for metrics. Grafana's Prometheus
datasource is provisioned. Logs and traces have no storage backend here.

```sh
./services up postgres
./services up redis
./services up observability
./services health
./services status
./services down
```

`up all` starts all profiles. Ports bind localhost and can be changed in `.env`.
Choose a unique `COMPOSE_PROJECT_NAME` for projects with the same directory name.
`stop` and `down` preserve named volumes. Seed, migrations and volume deletion
remain explicit. Images pin verified multiarchitecture manifest digests; update
tag and digest together. The local example credentials require review before
any server deployment.

The collector is distroless and exposes its health-check extension. The health
command uses Bun to query actual HTTP readiness endpoints. The optional real
engine test runs through `nix develop path:./devshell/bun-with-services --command
bash tests/containers.sh`; it cleans only its own temporary project and volumes.
