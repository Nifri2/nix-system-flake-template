# Shared desktop baseline: audio, printing/scanning, flatpak, browser.
# Not imported directly by hosts - each DE module (gnome/kde/hyprland)
# pulls this in. Servers simply import none of them.
{ config, lib, pkgs, ... }:

{
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
