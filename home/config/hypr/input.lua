-- Right Ctrl stays Compose. Omarchy's default is compose:caps.
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_options = "compose:rctrl",
    follow_mouse = 1,
    sensitivity = 0,
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    touchpad = {
      natural_scroll = false,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})

o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
