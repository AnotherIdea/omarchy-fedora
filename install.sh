#!/usr/bin/env bash
# Install Omarchy at the pinned tag, the Fedora packages, then the overlay.
# Package install asks for sudo. Existing personal config under ~/.config is left in place.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
tag=$(tr -d '[:space:]' <"$root/UPSTREAM")
dest=${OMARCHY_PATH:-$HOME/.local/share/omarchy}
cache=${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-fedora
tarball=$cache/omarchy-$tag.tar.gz
url=https://codeload.github.com/omacom/omarchy/tar.gz/refs/tags/$tag
ttfx_name=ttfx-0.5.0-3-x86_64.pkg.tar.zst
ttfx_url=https://pkgs.omarchy.org/stable/x86_64/$ttfx_name
tree_only=0
skip_packages=0

case ${1:-} in
  "") ;;
  --tree-only) tree_only=1 ;;
  --skip-packages) skip_packages=1 ;;
  *)
    echo "Usage: install.sh [--tree-only | --skip-packages]" >&2
    exit 2
    ;;
esac

as_root() {
  if [[ ${EUID} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

checksum() {
  local file=$1 name=$2
  awk -v file="$name" '$2 == file { print $1; exit }' "$root/SHA256SUMS"
}

fetch() {
  local dest_file=$1 src_url=$2 name=$3
  local expected
  expected=$(checksum "$dest_file" "$name")
  [[ -n $expected ]] || {
    echo "No checksum for $name" >&2
    exit 1
  }
  if [[ ! -f $dest_file ]] || [[ $(sha256sum "$dest_file" | awk '{ print $1 }') != "$expected" ]]; then
    curl -fsSL -o "$dest_file.partial" "$src_url"
    mv "$dest_file.partial" "$dest_file"
  fi
  [[ $(sha256sum "$dest_file" | awk '{ print $1 }') == "$expected" ]] || {
    echo "Checksum mismatch for $dest_file" >&2
    exit 1
  }
}

install_packages() {
  local pkg pkgs=()
  if rpm -q power-profiles-daemon >/dev/null 2>&1 || rpm -q tlp >/dev/null 2>&1; then
    echo "Remove power-profiles-daemon and tlp first. tuned-ppd cannot sit next to them." >&2
    exit 1
  fi
  while read -r pkg; do
    [[ -z $pkg || $pkg == \#* ]] && continue
    pkgs+=("$pkg")
  done <"$root/packages.txt"
  as_root dnf install -y dnf5-plugins
  as_root dnf -y copr enable lionheartp/Hyprland
  as_root dnf -y copr enable scottames/ghostty
  as_root dnf install -y "${pkgs[@]}"
}

mkdir -p "$cache"
if (( tree_only == 0 && skip_packages == 0 )); then
  install_packages
fi
fetch "$tarball" "$url" "omarchy-$tag.tar.gz"

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

# socat comes from the Fedora package. A copy in this tree would hide /usr/bin/socat.

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

ttfx_pkg=$cache/$ttfx_name
fetch "$ttfx_pkg" "$ttfx_url" "$ttfx_name"
ttfx_stage=$(mktemp -d)
tar -C "$ttfx_stage" -xf "$ttfx_pkg" usr/bin/ttfx
install -m 755 "$ttfx_stage/usr/bin/ttfx" "$dest/bin/ttfx"
rm -rf "$ttfx_stage"
mkdir -p "$HOME/.local/bin"
ln -sfn "$dest/bin/ttfx" "$HOME/.local/bin/ttfx"
# The old private socat hid /usr/bin/socat. Drop that link once the package is there.
if [[ -L $HOME/.local/bin/socat && -x /usr/bin/socat ]]; then
  rm -f "$HOME/.local/bin/socat"
fi

printf 'tree %s\n' "$dest"
[[ -n $backup ]] && printf 'backup %s\n' "$backup"
command -v socat >/dev/null 2>&1 || echo "socat is not on PATH. Re-run without --skip-packages." >&2
