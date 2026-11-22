-- Omarchy on Fedora. The tree lives in ~/.local/share/omarchy
-- because /usr/share/omarchy would need root.
-- Personal overrides stay in the other files under ~/.config/hypr.
-- This file is installed only when that path does not exist yet.

local home = os.getenv("HOME")
local omarchy = os.getenv("OMARCHY_PATH")
if omarchy == nil or omarchy == "" then
  omarchy = home .. "/.local/share/omarchy"
end

hl.env("OMARCHY_PATH", omarchy)
-- bootstrap replaces package.path and reads OMARCHY_PATH from the process
-- environment. Keep the tree on the search path either way.
package.path = omarchy .. "/?.lua;" .. package.path
dofile(omarchy .. "/default/hypr/bootstrap.lua")

require("default.hypr.omarchy")

require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

require("default.hypr.toggles")
