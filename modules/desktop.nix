# Desktop environment, audio, printing/scanning. Skip this import on servers.
{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Alternative: Hyprland instead of / next to GNOME
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Audio via pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.brlaser pkgs.hplip ];

  # Scanner support (SANE); add users to the "scanner" and "lp" groups.
  hardware.sane.enable = true;
  environment.systemPackages = with pkgs; [
    simple-scan
    sane-airscan
  ];

  services.flatpak.enable = true;
  programs.firefox.enable = true;
}
