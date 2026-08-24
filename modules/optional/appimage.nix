# Run unpackaged Linux binaries: AppImages plus nix-ld with the usual
# graphics/X11/audio libraries (portable Blender, vendor tools, ...).
{ config, lib, pkgs, ... }:

{
  programs.appimage = {
    enable = true;
    binfmt = true; # run AppImages directly
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Graphics + X11
    libGL libxkbcommon vulkan-loader
    xorg.libX11 xorg.libXi xorg.libXrandr xorg.libXfixes xorg.libXcursor
    xorg.libXrender xorg.libXxf86vm xorg.libXinerama xorg.libXext xorg.libXt
    xorg.libxcb xorg.libXau xorg.libXdmcp
    xorg.libSM xorg.libICE
    # System
    fontconfig freetype
    dbus alsa-lib libpulseaudio
    zlib zstd libusb1
    stdenv.cc.cc.lib
  ];
}
