# Omarchy 4.5 on Fedora

Upstream tag: `v4.5.0` (Quattro RS). The tree is `~/.local/share/omarchy`.
`/usr/share/omarchy` is not installed. Nothing here needs root.

Entry on a new machine: `~/.config/hypr/hyprland.lua`, copied by `install.sh` only when that file is absent. An existing file is left alone.

Fedora changes in this tree:

- `default/hypr/paths.lua` falls back to `~/.local/share/omarchy`.
- `default/hypr/autostart.lua` starts the shell and `hyprland-session.service`. It does not run the Arch first-run provisioner, `powerprofilesctl`, udiskie, or the clamshell monitor watcher. It sets `GTK_IM_MODULE=simple`. If `~/.local/bin/herdr` exists, it starts `herdr server`.
- `bin/omarchy-launch-terminal` uses `xdg-terminal-exec`, then Ghostty.
- `bin/omarchy-powerprofiles-list` and `bin/omarchy-powerprofiles-set` talk to `tuned-ppd` over D-Bus when `powerprofilesctl` is absent.
- `bin/omarchy-system` logout uses `loginctl terminate-session` when GDM did not start `wayland-wm@`.
- `bin/omarchy-inotifywait` uses `inotifywait` when `inotify-tools` is installed, otherwise it idles.
- The keyboard-layout widget skips `xkbcli` when that binary is absent.
- The power-profile menu reads the active profile from `omarchy-powerprofiles-list`.

`ttfx` and `socat` are not part of this overlay. An upgrade keeps the copies already in `bin/`.

Personal files stay on the machine. `install.sh` does not overwrite them: monitors, input, bindings, local autostart, shell.json, plugins, branding.
