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
local default_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}
config.window_padding = default_padding


wezterm.on("update-right-status", function(window, pane)
    local process_name = pane:get_foreground_process_name()
    if process_name and process_name:find("nvim") then
        window:set_config_overrides({
            window_padding = {
                left = 0, -- Custom Padding für nvim
                right = 0,
                top = 0,
                bottom = 0,
            }
        })
    else
        window:set_config_overrides({
            window_padding = default_padding
        })
    end
end)


-- Set Theme settings
config.window_background_opacity = 0.9
config.macos_window_background_blur = 100

local customSchemes = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
customSchemes.background = "#181825"
config.color_schemes = { ["SnicsThema"] = customSchemes }
config.color_scheme = "SnicsThema"
return config
