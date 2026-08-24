{ config, lib, pkgs, hostname, ... }:

let
  # Primary user of this machine. bootstrap.sh replaces this value.
  username = "user";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/apps.nix

    # Optional feature modules - uncomment what this machine needs:
    # ../../modules/optional/appimage.nix
    # ../../modules/optional/docker.nix
    # ../../modules/optional/gaming.nix
  ];

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
    # More groups as needed: "docker" "dialout" "adbusers" "plugdev" "scanner" "lp"
  };

  # Bootloader - systemd-boot for UEFI installs (the common case).
  # For a legacy BIOS/GRUB machine use instead:
  #   boot.loader.grub.enable = true;
  #   boot.loader.grub.device = "/dev/nvme0n1";
  #   boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Machine-specific extras (LUKS keyfiles, extra certs, udev rules,
  # GPU quirks, ...) belong here, next to the hardware config -
  # not in the shared modules.

  # Set by bootstrap.sh to the release you first installed with.
  # Never change it afterwards.
  system.stateVersion = "24.05";
}
