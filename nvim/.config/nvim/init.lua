-- Startup profiling: launch with PROF=1 nvim to profile startup
if vim.env.PROF then
    local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
    vim.opt.rtp:append(snacks)
    require("snacks.profiler").startup({
        startup = {
            event = "VimEnter",
            after = true,
        },
    })
end

require("config.options") -- set options
require("config.keymaps") -- set keymaps
require("config.lazy")    -- loading lazy.nvim with all the plugins
