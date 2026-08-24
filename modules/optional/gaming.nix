# Steam + gamescope.
{ config, lib, pkgs, ... }:

{
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Steam's desktop UI runs under Xwayland and can't read fractional
  # scaling; force explicit scaling instead of letting it auto-detect.
  environment.sessionVariables.STEAM_FORCE_DESKTOPUI_SCALING = "1";
}
