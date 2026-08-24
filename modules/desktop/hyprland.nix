# Hyprland (Wayland compositor) with SDDM as the login manager.
# Hyprland itself is configured per-user in ~/.config/hypr/hyprland.conf,
# not through NixOS options - this module only installs the stack.
{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.systemPackages = with pkgs; [
    waybar          # status bar
    wofi            # launcher
    hyprpaper       # wallpaper
    hyprlock        # screen lock
    wl-clipboard
    grim slurp      # screenshots
    mako            # notifications
  ];

  # Screen sharing / portals for wlroots-style compositors
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
