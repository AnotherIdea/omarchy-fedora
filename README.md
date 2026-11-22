# omarchy-fedora

Omarchy 4.5 (Quattro RS, tag `v4.5.0`) installé dans le home, sur Fedora.

Le dépôt contient le delta Fedora, `install.sh`, et quatre réglages de session : écrans, clavier, pavé, Super+B, OCR `fra+eng`.

Upstream reste [omacom/omarchy](https://github.com/omacom/omarchy). `install.sh` télécharge le tag, vérifie `SHA256SUMS`, copie `bin`, `config`, `default`, `shell`, `themes`, puis pose `overlay/`.

## Installer

```bash
./install.sh
```

Ça demande le mot de passe `sudo`, active les COPR `lionheartp/Hyprland` et `scottames/ghostty`, puis installe les paquets de `packages.txt`. Le Quickshell de Fedora est en 0.2 : trop vieux pour ce shell. Hyprland 0.57 et Quickshell 0.3 viennent du COPR.

`ttfx` n'a pas de paquet Fedora. Le script prend `ttfx` 0.5.0-3 sur pkgs.omarchy.org, vérifie le SHA256, et le pose dans `~/.local/share/omarchy/bin`. `socat` vient de Fedora.

L'arbre arrive dans `~/.local/share/omarchy`. Un arbre déjà là est renommé `omarchy.bak.<date>`.

`--skip-packages` ne relance pas `dnf`.

À chaque exécution, le script réécrit :

- `~/.config/hypr/monitors.lua` — `eDP-1` en 1080p, échelle 1, `HDMI-A-1` en miroir
- `~/.config/hypr/input.lua` — compose sur Ctrl droit, pavé sans défilement naturel
- `~/.config/hypr/bindings.lua` — Super+B ouvre le navigateur
- `~/.config/hypr/autostart.lua` — OCR `fra+eng`

S'ils manquent, il pose aussi :

- `~/.config/hypr/hyprland.lua` (chemin de l'arbre, puis les défauts Omarchy)
- `~/.config/environment.d/gtk-im-module.conf` (`GTK_IM_MODULE=simple`)
- `~/.config/systemd/user/hyprland-session.service` (portails sous GDM, sans UWSM)
- `~/.config/xdg-terminals.list` (Ghostty)

La session en cours ne recharge pas Hyprland. Une nouvelle connexion prend l'autostart. Relancer le shell avec `omarchy-restart-shell` recharge la barre.

## Ce qui reste sur la machine

- `~/.config/omarchy/shell.json`
- `~/.config/omarchy/plugins/`
- `~/.config/omarchy/branding/`
- les règles Promethee, jeux et veille navigateur (`promethee.lua`, `games.lua`, `browser.lua`)

Brave n'est pas un paquet du socle. Super+B lance le navigateur par défaut d'Omarchy.

`power-profiles-daemon` et TLP ne doivent pas être installés à côté de `tuned`. Le script s'arrête s'il les trouve.

Une nouvelle connexion charge les fichiers Hyprland. La session déjà ouverte garde l'ancienne config jusqu'au prochain login.
