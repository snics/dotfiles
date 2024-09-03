local wezterm = require('wezterm');

local config = wezterm.config_builder()

-- Set font settings
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16.0
config.term = "xterm-256color"

-- Setting the window title to the current running command
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.default_cursor_style = 'SteadyUnderline'

-- Default window padding
config.window_padding = {
  left = 10,
  right = 10,
  top = 0,
  bottom = 10,
}


-- Set Theme settings
config.window_background_opacity = 0.9
config.macos_window_background_blur = 100

local customSchemes = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
customSchemes.background = "#181825"
config.color_schemes = { ["SnicsThema"] = customSchemes }
config.color_scheme = "SnicsThema"
return config