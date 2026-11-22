-- ThinkPad eDP-1 is 1080p. Hyprland's auto scale picks 1.5 on the panel
-- and 2 on the Vestel TV (tiny EDID). Force 1x and mirror the TV onto the panel.
hl.env("GDK_SCALE", "1")

hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
  mirror = "eDP-1",
})
