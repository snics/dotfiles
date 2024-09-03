return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      "                                                   ",
      "    ____            _   ___         _              ",
      "   / __ \\___ _   __/ | / (_)___    (_)___ ______  ",
      "  / / / / _ \\ | / /  |/ / / __ \\  / / __ `/ ___/ ",
      " / /_/ /  __/ |/ / /|  / / / / / / / /_/ (__  )    ",
      "/_____/\\___/|___/_/ |_/_/_/ /_/_/ /\\__,_/____/  ",
      "                             /___/                 ",
      "                                                   ",
    }

    -- Set sections
    startify.file_icons.provider = "devicons"

    -- Set the color for the header
    vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = '#7A59B0', bg = 'NONE' }) -- Gold color
    -- Apply the highlight to the header
    dashboard.section.header.opts.hl = 'AlphaHeader'

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"), -- Open new file
      dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"), -- Toggle file explorer
      dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"), -- Find file
      dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"), -- Find word
      dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"), -- Restore session
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"), -- Quit
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}