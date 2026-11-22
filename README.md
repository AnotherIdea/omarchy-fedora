# omarchy-fedora

Omarchy 4.5 (Quattro RS, tag `v4.5.0`) installé dans le home, sur Fedora.

Le dépôt contient le delta Fedora et `install.sh`. Il ne contient pas la configuration de la machine : écrans, clavier, raccourcis, barre, plugins, thèmes perso.

Upstream reste [omacom/omarchy](https://github.com/omacom/omarchy). `install.sh` télécharge le tag, vérifie `SHA256SUMS`, copie `bin`, `config`, `default`, `shell`, `themes`, puis pose `overlay/`.

## Installer

```bash
./install.sh
```

Ça demande le mot de passe `sudo`, active les COPR `lionheartp/Hyprland` et `scottames/ghostty`, puis installe les paquets de `packages.txt`. Le Quickshell de Fedora est en 0.2 : trop vieux pour ce shell. Hyprland 0.57 et Quickshell 0.3 viennent du COPR.

`ttfx` n'a pas de paquet Fedora. Le script prend `ttfx` 0.5.0-3 sur pkgs.omarchy.org, vérifie le SHA256, et le pose dans `~/.local/share/omarchy/bin`. `socat` vient de Fedora.

L'arbre arrive dans `~/.local/share/omarchy`. Un arbre déjà là est renommé `omarchy.bak.<date>`.

Le script ne remplace pas un fichier déjà présent sous `~/.config`. `--skip-packages` ne relance pas `dnf`.

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
Brave, les règles de fenêtres et le plugin XMR ne sont pas des paquets du socle.

`power-profiles-daemon` et TLP ne doivent pas être installés à côté de `tuned`. Le script s'arrête s'il les trouve.

OCR : si tu veux `fra+eng`, mets `hl.env("OMARCHY_OCR_LANGS", "fra+eng")` dans ton `~/.config/hypr/autostart.lua`. Ce n'est pas dans le dépôt.
