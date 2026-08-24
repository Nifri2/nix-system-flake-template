# KDE Plasma 6 on Wayland with SDDM.
{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Trim the default Plasma app set if you like:
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa khelpcenter ];
}
