return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine") -- to configure lualine
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    local colors = {
      blue = "#89b4fa",
      green = "#a6e3a1",
      violet = "#cba6f7",
      yellow = "#f9e2af",
      red = "#f38ba8",
      fg = "#cdd6f4",
      bg = "#313244",
      inactive_bg = "#313244",
    }

    local lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.semilightgray },
        c = { bg = colors.inactive_bg, fg = colors.semilightgray },
      },
    }

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = lualine_theme,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_c = {
          { "filename" },
          -- YAML-Pfad-Anzeige
          {
            function()
              if vim.bo.filetype == "yaml" then
                local ok, yaml = pcall(require, "yaml_nvim")
                if ok then
                  local yaml_path = yaml.get_yaml_key()
                  if yaml_path and yaml_path ~= "" then
                    -- Nutze das YAML-Icon aus nvim-web-devicons
                    local devicons = require("nvim-web-devicons")
                    local yaml_icon = devicons.get_icon_by_filetype("yaml") or ""
                    return yaml_icon .. " " .. yaml_path
                  end
                end
              end
              return ""
            end,
            cond = function()
              return vim.bo.filetype == "yaml"
            end,
            color = { gui = "italic" },
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#fab387" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}