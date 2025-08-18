-- https://wezterm.org/config/files.html-
-- Pull in the wezterm API
local wezterm = require("wezterm")
local action = wezterm.action
local SendKey = action.SendKey

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
local opts = {
	window_decorations = "RESIZE",
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = false,
	enable_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	initial_rows = 120,
	initial_cols = 220,
	-- color_scheme = "tokyonight-storm",
	-- color_scheme = "BlulocoDark",
	-- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/ComicShannsMono.zip
	font = wezterm.font("ComicShannsMono Nerd Font"),
	font_size = 15,
	audible_bell = "Disabled",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	keys = {
		{ key = "LeftArrow", mods = "OPT", action = action({ SendString = "\x1bb" }) },
		{ key = "RightArrow", mods = "OPT", action = action({ SendString = "\x1bf" }) },
		{ key = "h", mods = "OPT", action = SendKey({ key = "LeftArrow" }) },
		{ key = "l", mods = "OPT", action = SendKey({ key = "RightArrow" }) },
	},
}

for k, v in pairs(opts) do
	config[k] = v
end

-- and finally, return the configuration to wezterm
return config
