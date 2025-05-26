-- local settings = require("settings")
--
-- -- Add the item
-- os.execute("sketchybar --add item space_display left")
-- os.execute(
-- 	"sketchybar --set space_display "
-- 		.. "label.font='"
-- 		.. (settings.font.text or "JetBrainsMono Nerd Font")
-- 		.. ":Regular:14.0' "
-- 		.. "label.color=0xffffffff "
-- 		.. "label.padding_left=10 "
-- 		.. "label.padding_right=10 "
-- 		.. "icon.drawing=off "
-- 		.. "updates=on "
-- 		.. "script="
-- 		.. settings.plugins
-- 		.. "/workspace_name.sh"
-- )
--
-- -- Subscribe to events
-- os.execute("sketchybar --subscribe space_display aerospace_workspace_change")
local sbar = require("sketchybar")

sbar.add("item", "space_display", {
	position = "left",
	label = {
		text = "TEST",
		color = 0xffffffff,
		font = "JetBrainsMono Nerd Font:Regular:14.0",
	},
	icon = {
		drawing = false,
	},
})
