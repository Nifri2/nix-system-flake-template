# System-wide packages. Keep this to tools every machine wants;
# machine-specific software goes into the host's default.nix.
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors / VCS
    vim
    git
    gh
    delta

    # Workflow tooling this repo's Taskfile + hooks rely on
    nh
    go-task
    lefthook

    # CLI basics
    wget
    curl
    fastfetch
    killall
    usbutils
    lsof
    fzf
    fd
    eza
    starship
    p7zip
    ffmpeg
    yt-dlp

    # Terminal
    kitty
  ];

  # If a package needs an insecure-marked dependency, whitelist it
  # deliberately and leave a comment why:
  # nixpkgs.config.permittedInsecurePackages = [ ];
}
