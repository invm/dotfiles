-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'tokyonight-storm'
config.color_scheme = "BlulocoDark"
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
-- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/ComicShannsMono.zip
config.font = wezterm.font("ComicShannsMono Nerd Font")
config.font_size = 13
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- and finally, return the configuration to wezterm
return config