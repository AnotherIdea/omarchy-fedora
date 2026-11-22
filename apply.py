#!/usr/bin/env python3
"""Surgical Fedora edits on Omarchy 4.5 QML. Fails if an anchor moved."""

import sys
from pathlib import Path

REPLACEMENTS = {
    "shell/plugins/bar/widgets/KeyboardLayout.qml": (
        'command: ["xkbcli", "list", "--load-exotic"]',
        'command: ["sh", "-c", "command -v xkbcli >/dev/null 2>&1 && exec xkbcli list --load-exotic || true"]',
    ),
    "shell/plugins/menu/Menu.qml": (
        "current=$(powerprofilesctl get 2>/dev/null)",
        "current=$(omarchy-powerprofiles-list --active-state 2>/dev/null | awk '$2==1 { print $1; exit }')",
    ),
    "shell/services/PluginRegistry.qml": (
        """    command: [
      "inotifywait",
      "-m",
      "-r",
      "-q",
      "-e",
      "close_write,create,delete,move",
      "--format",
      "%w%f",
      registry.pluginsDir
    ]""",
        '    command: ["omarchy-inotifywait", registry.pluginsDir]',
    ),
}


def main() -> None:
    root = Path(sys.argv[1])
    for rel, (old, new) in REPLACEMENTS.items():
        path = root / rel
        text = path.read_text()
        count = text.count(old)
        if count != 1:
            raise SystemExit(f"{rel}: expected 1 anchor, found {count}")
        path.write_text(text.replace(old, new, 1))


if __name__ == "__main__":
    main()
