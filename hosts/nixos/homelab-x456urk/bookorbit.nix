# BookOrbit has no native NixOS module. It is the one service that runs as
# containers: the official app image plus its pgvector PostgreSQL sidecar.
# Everything is local: SQLite-free app data and Postgres live under /persist,
# while the library stays on the XFS media disk.
{
  config,
  ...
}:
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      bookorbit-postgres = {
        image = "docker.io/pgvector/pgvector:pg18";
        environmentFiles = [ config.sops.secrets.bookorbit_env.path ];
        environment.PGDATA = "/var/lib/postgresql/data/pgdata";
        volumes = [ "/var/lib/bookorbit/postgres:/var/lib/postgresql/data" ];
      };

      bookorbit-app = {
        image = "ghcr.io/bookorbit/bookorbit:latest";
        environmentFiles = [ config.sops.secrets.bookorbit_env.path ];
        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          BOOKS_HOST_PATH = "/books";
          PUID = toString config.users.users.atalariq.uid;
          PGID = toString config.users.groups.media.gid;
        };
        volumes = [
          "/data/media/books:/books"
          "/var/lib/bookorbit/app:/data"
        ];
        ports = [ "3000:3000" ];
        dependsOn = [ "bookorbit-postgres" ];
      };
    };
  };

  systemd.services."podman-bookorbit-app" = {
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
  };
}
