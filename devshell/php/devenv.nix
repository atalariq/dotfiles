# Project-local replacement for the removed Lerd NixOS integration: copy this
# directory into a project, run `devenv shell` for php 8.4, composer and a
# MariaDB client, then `devenv up` to start php-fpm, MariaDB and Caddy.
#
# Only this project's runtime state and containers are created. The host keeps
# no Lerd package, unit, DNS delegate or privileged port setting.
{
  config,
  pkgs,
  ...
}:
{
  languages.php = {
    enable = true;
    version = "8.4";
    # One pool is enough for local development; php-fpm is started by `devenv up`.
    fpm.pools.web.settings = {
      "pm" = "dynamic";
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
    };
  };

  # MariaDB is devenv's default mysql package; one project database keeps the
  # first run deterministic.
  services.mysql = {
    enable = true;
    initialDatabases = [ { name = "app"; } ];
  };

  # Serves ./public through php-fpm on http://localhost:8000.
  services.caddy = {
    enable = true;
    virtualHosts."http://localhost:8000".extraConfig = ''
      root * public
      php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}
      file_server
    '';
  };

  # Composer needs these at runtime to download and unpack dependencies.
  packages = [
    pkgs.git
    pkgs.unzip
  ];
}
