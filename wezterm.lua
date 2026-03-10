-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.adjust_window_size_when_changing_font_size = false
-- config.color_scheme = "Ayu Dark (Gogh))"
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}
config.line_height = 0.9

config.enable_tab_bar = false

config.font_size = 13

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.font = wezterm.font("comicshannsmono nerd font", { weight = "Bold" })

config.window_background_opacity = 0.8
config.macos_window_background_blur = 40

-- and finally, return the configuration to wezterm
return config
