# PHP devenv template

Copy `devenv.yaml` and `devenv.nix` into a project root, then run these from that
directory:

```sh
devenv shell   # php 8.4, composer, MariaDB client tools
devenv up      # php-fpm `web` pool, MariaDB (database `app`), Caddy on :8000
```

Caddy serves `./public` through php-fpm at <http://localhost:8000>. The first
run writes `devenv.lock` and project-local runtime state; keep the lock with the
project so copies resolve the same nixpkgs revision.

This replaces the former host-level Lerd integration. Existing Lerd containers
and project data are untouched; migrate each project by copying this template and
moving its database/webserver settings here.
