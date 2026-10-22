{ config, checkout, ... }:
{
  # Optional native settings; credentials and runtime state remain in ~/.hermes.
  home.file.".hermes/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/hermes/config/config.yaml";
}
