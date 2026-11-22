#!/usr/bin/env bash
# Install Omarchy at the pinned tag, then the Fedora overlay.
# No sudo. Existing personal config under ~/.config is left in place.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
tag=$(tr -d '[:space:]' <"$root/UPSTREAM")
dest=${OMARCHY_PATH:-$HOME/.local/share/omarchy}
cache=${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-fedora
tarball=$cache/omarchy-$tag.tar.gz
url=https://codeload.github.com/omacom/omarchy/tar.gz/refs/tags/$tag
tree_only=0

if [[ ${1:-} == --tree-only ]]; then
  tree_only=1
elif [[ -n ${1:-} ]]; then
  echo "Usage: install.sh [--tree-only]" >&2
  exit 2
fi

mkdir -p "$cache"
expected=$(awk -v file="omarchy-$tag.tar.gz" '$2 == file { print $1; exit }' "$root/SHA256SUMS")
[[ -n $expected ]] || {
  echo "No checksum for omarchy-$tag.tar.gz" >&2
  exit 1
}

have_hash() {
  sha256sum "$tarball" | awk '{ print $1 }'
}

if [[ ! -f $tarball ]] || [[ $(have_hash) != "$expected" ]]; then
  curl -fsSL -o "$tarball.partial" "$url"
  mv "$tarball.partial" "$tarball"
fi
[[ $(have_hash) == "$expected" ]] || {
  echo "Checksum mismatch for $tarball" >&2
  exit 1
}

stage=$(mktemp -d)
cleanup() { rm -rf "$stage"; }
trap cleanup EXIT

tar -xzf "$tarball" -C "$stage"
src=$(echo "$stage"/omarchy-*)
work=$stage/tree
mkdir -p "$work"
cp -a "$src/bin" "$src/config" "$src/default" "$src/shell" "$src/themes" "$work/"
cp -a "$src/logo.txt" "$src/version" "$work/"
cp -a "$root/overlay/." "$work/"
python3 "$root/apply.py" "$work"
chmod 755 "$work/bin/omarchy-inotifywait" \
  "$work/bin/omarchy-launch-terminal" \
  "$work/bin/omarchy-powerprofiles-list" \
  "$work/bin/omarchy-powerprofiles-set" \
  "$work/bin/omarchy-system"

# Screensaver binaries are not in this repo. Keep the ones already installed.
if [[ -d $dest/bin ]]; then
  for bin in ttfx socat; do
    if [[ -f $dest/bin/$bin && ! -e $work/bin/$bin ]]; then
      cp -a "$dest/bin/$bin" "$work/bin/$bin"
    fi
  done
fi

backup=""
if [[ -e $dest ]]; then
  backup=${dest}.bak.$(date +%Y%m%d%H%M%S)
  mv "$dest" "$backup"
fi
mkdir -p "$(dirname "$dest")"
if ! mv "$work" "$dest"; then
  if [[ -n $backup ]]; then
    mv "$backup" "$dest"
  fi
  echo "Could not move the new tree into $dest" >&2
  exit 1
fi
trap - EXIT
rm -rf "$stage"

# Point the share-tree template at the home install. User ~/.config is separate.
cp -a "$root/home/config/hypr/hyprland.lua" "$dest/config/hypr/hyprland.lua"

if (( tree_only )); then
  printf 'tree %s\n' "$dest"
  [[ -n $backup ]] && printf 'backup %s\n' "$backup"
  exit 0
fi

install_if_missing() {
  local src_file=$1 dest_file=$2 mode=$3
  if [[ -e $dest_file ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$dest_file")"
  cp -a "$src_file" "$dest_file"
  chmod "$mode" "$dest_file"
  printf 'installed %s\n' "$dest_file"
}

# Upstream stubs, only where the user has no file yet.
for name in autostart.lua bindings.lua input.lua looknfeel.lua monitors.lua xdph.conf hyprsunset.conf; do
  if [[ -f $dest/config/hypr/$name ]]; then
    install_if_missing "$dest/config/hypr/$name" "$HOME/.config/hypr/$name" 644
  fi
done

install_if_missing "$root/home/config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua" 644
install_if_missing "$root/home/config/environment.d/gtk-im-module.conf" "$HOME/.config/environment.d/gtk-im-module.conf" 644
install_if_missing "$root/home/config/systemd/user/hyprland-session.service" "$HOME/.config/systemd/user/hyprland-session.service" 644
install_if_missing "$root/home/config/xdg-terminals.list" "$HOME/.config/xdg-terminals.list" 644

if [[ -f $HOME/.config/systemd/user/hyprland-session.service ]]; then
  systemctl --user daemon-reload
fi

mkdir -p "$HOME/.local/bin"
for bin in ttfx socat; do
  if [[ -f $dest/bin/$bin ]]; then
    ln -sfn "$dest/bin/$bin" "$HOME/.local/bin/$bin"
  fi
done

printf 'tree %s\n' "$dest"
[[ -n $backup ]] && printf 'backup %s\n' "$backup"
if [[ ! -x $dest/bin/ttfx || ! -x $dest/bin/socat ]]; then
  echo "Screensaver still needs ttfx and socat in $dest/bin. This repo does not ship those binaries." >&2
fi
