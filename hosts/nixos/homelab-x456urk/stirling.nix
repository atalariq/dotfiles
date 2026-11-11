# Stirling PDF ships as a web app in a container and as a Gradle build in
# nixpkgs. The container is the upstream-supported deployment and starts in
# seconds; the source build drags in a full Gradle and npm toolchain for a
# service that only needs a PDF pipeline. Follow BookOrbit's pattern: keep the
# container, keep its config on the persistence root.
{
  virtualisation.oci-containers.containers.stirling-pdf = {
    image = "docker.io/stirlingtools/stirling-pdf:latest";
    ports = [ "8082:8080" ];
    volumes = [ "/var/lib/stirling-pdf:/configs" ];
    environment = {
      DOCKER_ENABLE_SECURITY = "false";
      INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "false";
    };
  };
}
