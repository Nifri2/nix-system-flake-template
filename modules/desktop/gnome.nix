# GNOME on Wayland with GDM.
{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Trim the default GNOME app set if you like:
  # environment.gnome.excludePackages = with pkgs; [ epiphany geary ];
}
