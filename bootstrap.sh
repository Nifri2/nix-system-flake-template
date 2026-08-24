#!/usr/bin/env bash
#
# Bootstrap this flake template onto a fresh NixOS machine.
#
# Run from the repo root on the target machine (after a normal NixOS
# install, e.g. via the graphical installer):
#
#   git clone <your-template-repo> ~/nix && cd ~/nix && ./bootstrap.sh
#
# What it does:
#   1. Creates hosts/<hostname>/ from hosts/example/
#   2. Fills in your username, hostname and the installed NixOS release
#   3. Generates the real hardware-configuration.nix
#   4. Commits everything (flakes only see git-tracked files)
#   5. Optionally runs the first `nixos-rebuild switch --flake`
#
# Safe to re-run: it refuses to overwrite an existing host directory.

set -euo pipefail

err()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[32m==>\033[0m %s\n' "$*"; }

cd "$(dirname "$0")"

[ -f flake.nix ] || err "run this from the repo root (flake.nix not found)"
[ -f /etc/NIXOS ] || err "this doesn't look like a NixOS system"
command -v git >/dev/null || err "git not found (try: nix-shell -p git)"

# --- gather host facts -------------------------------------------------------

default_host="$(hostname)"
read -rp "Hostname for this machine [${default_host}]: " HOST
HOST="${HOST:-$default_host}"
[[ "$HOST" =~ ^[a-zA-Z0-9-]+$ ]] || err "hostname must be alphanumeric/dashes"

default_user="${SUDO_USER:-$USER}"
read -rp "Primary username [${default_user}]: " NEWUSER
NEWUSER="${NEWUSER:-$default_user}"
[[ "$NEWUSER" =~ ^[a-z_][a-z0-9_-]*$ ]] || err "invalid username"

echo "Desktop environment:"
echo "  1) GNOME"
echo "  2) KDE Plasma"
echo "  3) Hyprland"
echo "  4) none (headless/server)"
read -rp "Select [1-4, default 1]: " de_choice
case "${de_choice:-1}" in
  1) DE="gnome" ;;
  2) DE="kde" ;;
  3) DE="hyprland" ;;
  4) DE="none" ;;
  *) err "invalid selection: ${de_choice}" ;;
esac

# stateVersion = the release this machine was first installed with
STATE_VERSION="$(nixos-version | grep -oE '^[0-9]+\.[0-9]+')"
[ -n "$STATE_VERSION" ] || err "could not determine NixOS release from nixos-version"

info "host: $HOST, user: $NEWUSER, desktop: $DE, stateVersion: $STATE_VERSION"

# --- create the host directory ----------------------------------------------

HOSTDIR="hosts/$HOST"
if [ -d "$HOSTDIR" ]; then
  err "$HOSTDIR already exists - delete it first if you want to re-bootstrap"
fi

info "creating $HOSTDIR from hosts/example"
cp -r hosts/example "$HOSTDIR"

sed -i "s/username = \"user\";/username = \"$NEWUSER\";/" "$HOSTDIR/default.nix"
sed -i "s/system.stateVersion = \"[0-9.]*\";/system.stateVersion = \"$STATE_VERSION\";/" "$HOSTDIR/default.nix"

if [ "$DE" = "none" ]; then
  # drop the desktop import (and the comment block above it stays harmless)
  sed -i '\|modules/desktop/|d' "$HOSTDIR/default.nix"
else
  sed -i "s|modules/desktop/gnome.nix|modules/desktop/$DE.nix|" "$HOSTDIR/default.nix"
fi

info "generating hardware-configuration.nix (needs sudo)"
sudo nixos-generate-config --show-hardware-config > "$HOSTDIR/hardware-configuration.nix"

# Keep the bootloader choice honest: warn if the installed system is
# legacy BIOS but the template defaults to systemd-boot.
if [ ! -d /sys/firmware/efi ]; then
  cat <<'EOF'
NOTE: this machine booted in legacy BIOS mode. Edit your host's
default.nix and swap systemd-boot for GRUB (see the comment there)
before switching!
EOF
fi

# --- git + first build -------------------------------------------------------

if [ ! -d .git ]; then
  info "initializing git repository"
  git init -q
fi

git add -A
if ! git diff --cached --quiet; then
  info "committing bootstrap state"
  git commit -q -m "bootstrap: add host $HOST"
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

info "evaluating flake"
nix flake show >/dev/null

read -rp "Build and switch to the new system now? [y/N]: " yn
if [[ "${yn,,}" == "y" ]]; then
  sudo nixos-rebuild switch --flake ".#$HOST"
  info "done - system switched. Daily workflow from now on: task update / build / deploy"
else
  cat <<EOF
Skipped. When ready, run:
  sudo nixos-rebuild switch --flake .#$HOST
Afterwards (nh, go-task, lefthook are installed by modules/apps.nix):
  task update && task build && task deploy
EOF
fi
