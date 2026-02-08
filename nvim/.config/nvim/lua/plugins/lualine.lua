-- Statusline. Available options: theme, component/section_separators, globalstatus,
--   disabled_filetypes, refresh, sections (lualine_a-z), extensions.
-- Built-in components: mode, branch, diff, diagnostics, filename, encoding, fileformat,
--   filetype, progress, location, searchcount, selectioncount
-- Built-in extensions: quickfix, trouble, lazy, mason, nvim-dap-ui, toggleterm, neo-tree, oil
return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            theme = "auto",                                   -- default: "auto" — auto-detects catppuccin/etc.
            component_separators = { left = "", right = "" }, -- default: { left="", right="" }
            -- section_separators use default: { left="", right="" }
            globalstatus = true,                              -- default: from laststatus — single statusline
        },
        sections = {
            -- lualine_a = { "mode" },          -- default
            -- lualine_b = { "branch", "diff", "diagnostics" }, -- default
            lualine_c = {
                { "filename" },
                -- YAML path display (requires cuducos/yaml.nvim)
                {
                    function()
                        local ok, yaml = pcall(require, "yaml_nvim")
                        if ok then
                            local yaml_path = yaml.get_yaml_key()
                            if yaml_path and yaml_path ~= "" then
                                local devicons = require("nvim-web-devicons")
                                local yaml_icon = devicons.get_icon_by_filetype("yaml") or ""
                                return yaml_icon .. " " .. yaml_path
                            end
                        end
                        return ""
                    end,
                    cond = function() return vim.bo.filetype == "yaml" end,
                    color = { gui = "italic" },
                },
                -- YAML schema (via yaml-companion)
                {
                    function()
                        local ok, companion = pcall(require, "yaml-companion")
                        if ok then
                            local schema = companion.get_buf_schema(0)
                            if schema and schema.result[1] and schema.result[1].name ~= "none" then
                                return schema.result[1].name
                            end
                        end
                        return ""
                    end,
                    cond = function() return vim.bo.filetype == "yaml" end,
                    color = { fg = "#fab387" },
                },
            },
            lualine_x = {
                {
                    require("lazy.status").updates,
                    cond = require("lazy.status").has_updates,
                    color = { fg = "#fab387" },
                },
                { "encoding" },   -- default
                { "fileformat" }, -- default
                { "filetype" },   -- default
            },
            -- lualine_y = { "progress" },      -- default
            -- lualine_z = { "location" },      -- default
        },
        extensions = { "quickfix", "trouble", "lazy", "mason", "nvim-dap-ui" },
    },
}
