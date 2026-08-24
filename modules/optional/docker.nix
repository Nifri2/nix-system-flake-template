# Docker. Remember to add your user to the "docker" group in the host config.
{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # Machine-specific daemon settings (moved data-root, insecure registries)
  # belong in the host config, e.g.:
  # virtualisation.docker.daemon.settings = {
  #   data-root = "/data/docker";
  #   insecure-registries = [ "registry.example.internal" ];
  # };
}
