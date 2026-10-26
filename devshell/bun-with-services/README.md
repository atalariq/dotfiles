# bun-with-services

Core packages: `bun`, `podman`, `podman-compose`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

Services are opt-in. See the service commands below; entering this shell never starts a container.

Update `flake.lock` deliberately; it records the toolchain versions.

## Services

Grafana defaults to <http://127.0.0.1:3001>, leaving Bun's usual port 3000 free.

Optionally copy `.env.example` to `.env` and choose local credentials/ports.
Use a distinct `COMPOSE_PROJECT_NAME` for projects that share a directory name.

```sh
podman-compose --profile postgres up -d
podman-compose --profile redis up -d
podman-compose --profile observability up -d
podman-compose ps
podman-compose down
```

`--profile '*' up -d` starts every profile. `stop` and `down` preserve volumes. Data deletion,
migrations and seeds are separate, deliberate operations. Ports bind localhost.
Images have verified Linux amd64/arm64 manifest digests. The observability
profile accepts OTLP **metrics**, which Prometheus scrapes and Grafana displays
through its provisioned Prometheus datasource. Logs and traces are not stored.
The collector exposes its health extension; check HTTP readiness endpoints
directly with curl and inspect compose health status. `.envrc` only loads
the toolchain; it does not export service credentials. Review credentials, exposure and backups before server deployment.
