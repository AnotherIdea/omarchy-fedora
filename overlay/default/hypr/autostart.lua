require("default.hypr.startup-cursor")

-- GTK 4.20+ on Wayland drops Compose unless an input module is set.
hl.env("GTK_IM_MODULE", "simple")

hl.on("hyprland.start", function()
  -- Applications inherit the user's cursor; only the compositor starts blank.
  if omarchy_startup_cursor_pending then
    hl.env("XCURSOR_PATH", omarchy_startup_cursor.path)
    hl.env("XCURSOR_THEME", omarchy_startup_cursor.xcursor)
  end

  -- Slow app launch fix -- set systemd and D-Bus activation vars before
  -- starting session services.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- GDM starts Hyprland without UWSM, so graphical-session.target never
  -- comes up on its own. hyprland-session.service pulls it in as a
  -- dependency (it refuses a manual start) so xdg-desktop-portal can run.
  hl.exec_cmd("systemctl --user start hyprland-session.service")

  hl.exec_cmd("omarchy-launch-shell")

  -- Not an Arch install:
  -- omarchy-provision-first-run would run the Arch user provisioner.
  -- omarchy-powerprofiles-init would call powerprofilesctl; tuned stays in charge.
  -- udiskie is not installed.
  -- The clamshell monitor watcher rewrites outputs. Mirror lines belong in
  -- the local ~/.config/hypr/monitors.lua, which this repo does not ship.

  -- herdr is a user binary, outside the Hyprland session PATH.
  local home = os.getenv("HOME") or ""
  local herdr = home .. "/.local/bin/herdr"
  local herdr_file = io.open(herdr, "r")
  if herdr_file then
    herdr_file:close()
    hl.exec_cmd(o.launch(herdr .. " server"))
  end

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
