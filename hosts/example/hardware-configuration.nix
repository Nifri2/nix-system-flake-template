# PLACEHOLDER - replaced by bootstrap.sh with the real output of
#   nixos-generate-config --show-hardware-config
# The dummy filesystem below only exists so `nix flake check` can
# evaluate the template before bootstrapping. Do not boot from this.
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
