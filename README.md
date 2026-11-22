# omarchy-fedora

Omarchy 4.5 (Quattro RS, tag `v4.5.0`) installé dans le home, sur Fedora, sans root.

Le dépôt contient le delta Fedora et `install.sh`. Il ne contient pas la configuration de la machine : écrans, clavier, raccourcis, barre, plugins, thèmes perso.

Upstream reste [omacom/omarchy](https://github.com/omacom/omarchy). `install.sh` télécharge le tag, vérifie `SHA256SUMS`, copie `bin`, `config`, `default`, `shell`, `themes`, puis pose `overlay/`.

## Installer

```bash
./install.sh
```

L'arbre arrive dans `~/.local/share/omarchy`. Un arbre déjà là est renommé `omarchy.bak.<date>`.

Aucun `sudo`. Le script ne remplace pas un fichier déjà présent sous `~/.config`.

Sur une machine vide, il pose seulement :

- `~/.config/hypr/hyprland.lua` (chemin de l'arbre, puis les défauts Omarchy)
- les modèles Hyprland upstream, s'ils manquent (`monitors.lua`, `input.lua`, …)
- `~/.config/environment.d/gtk-im-module.conf` (`GTK_IM_MODULE=simple`)
- `~/.config/systemd/user/hyprland-session.service` (portails sous GDM, sans UWSM)
- `~/.config/xdg-terminals.list` (Ghostty)

La session en cours ne recharge pas Hyprland. Une nouvelle connexion prend l'autostart. Relancer le shell avec `omarchy-restart-shell` recharge la barre.

## Ce qui reste sur la machine

- `~/.config/hypr/` une fois qu'il existe (écrans, clavier, raccourcis, règles de fenêtres)
- `~/.config/omarchy/shell.json`
- `~/.config/omarchy/plugins/`
- `~/.config/omarchy/branding/`
- les binaires `ttfx` et `socat` (recopiés depuis l'ancien arbre, pas versionnés)

L'écran de veille a besoin de `ttfx` et de `socat` dans `~/.local/share/omarchy/bin`. Fedora a un paquet `socat`. `ttfx` n'a pas de paquet Fedora. Ne pas installer `power-profiles-daemon` ni TLP à côté de `tuned`.

OCR : si tu veux `fra+eng`, mets `hl.env("OMARCHY_OCR_LANGS", "fra+eng")` dans ton `~/.config/hypr/autostart.lua`. Ce n'est pas dans le dépôt.
