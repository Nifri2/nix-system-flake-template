# NixOS System Flake Template

Reusable multi-host NixOS flake, extracted from a personal `~/nix` config.
One repo, one directory per machine, shared modules, and a `Taskfile`-driven
workflow around [`nh`](https://github.com/nix-community/nh).

## Layout

```
flake.nix                 # auto-discovers every directory under hosts/
Taskfile.yaml             # daily workflow: task update / build / deploy
bootstrap.sh              # sets up a fresh machine (see below)
lefthook.yml              # pre-commit: parse + flake check
hosts/
  example/                # copied by bootstrap.sh for each new machine
    default.nix           # user, bootloader, machine-specific settings
    hardware-configuration.nix   # placeholder, replaced by bootstrap
modules/
  core.nix                # nix settings, gc, locale, networking, fish
  desktop/
    common.nix            # pipewire, printing/scanning, flatpak (pulled in by the DE modules)
    gnome.nix             # GNOME + GDM
    kde.nix               # KDE Plasma 6 + SDDM
    hyprland.nix          # Hyprland + SDDM + waybar/wofi/mako basics
  apps.nix                # shared package set (incl. nh, go-task, lefthook)
  optional/
    appimage.nix          # appimage binfmt + nix-ld library set
    docker.nix
    gaming.nix            # steam + gamescope
```

Every directory under `hosts/` automatically becomes a
`nixosConfiguration` with the same name - adding a machine never
requires touching `flake.nix`.

## New machine

Install NixOS normally (installer of your choice), then:

```sh
git clone <this-repo> ~/nix
cd ~/nix
./bootstrap.sh
```

The script asks for hostname, username and desktop environment
(GNOME / KDE Plasma / Hyprland / none for servers), creates
`hosts/<hostname>/` from the example, generates the real
`hardware-configuration.nix`, pins `system.stateVersion` to the
installed release, commits, and offers to run the first
`nixos-rebuild switch --flake .#<hostname>`.

To change DE later, just swap the `modules/desktop/*.nix` import in
your host's `default.nix` and rebuild.

After the first switch, `nh`, `go-task` and `lefthook` are installed
system-wide and the daily workflow applies.

## Daily workflow

```sh
task            # list all tasks
task update     # bump flake inputs (only touches flake.lock)
task check      # parse + evaluate, fast, no root
task build      # full build without activating
task test       # activate but don't make it the boot default (reboot = rollback)
task deploy     # switch + set boot default (asks first)
task rollback   # previous generation
```

`nh` targets the config matching the machine's hostname; use
`task build HOST=otherhost` to build for another machine.

Optional: `lefthook install` enables the pre-commit checks.

## Conventions

- **Shared vs. host-specific:** anything with UUIDs, absolute home
  paths, certificates, GPU quirks or udev rules for specific devices
  goes in `hosts/<name>/default.nix`, never in `modules/`.
- **Secrets/certificates** are gitignored (`*.pem`, `*.crt`, `*.key`).
  Reference them from an absolute path outside the repo, or use
  agenix/sops-nix if you want them in-repo.
- **Path inputs** (`url = "path:/..."`) force `--impure` on every
  build - if you add one, append `-- --impure` to the `nh` calls in
  `Taskfile.yaml`. Prefer git URLs.
- `system.stateVersion` is set once by bootstrap and never changed.
