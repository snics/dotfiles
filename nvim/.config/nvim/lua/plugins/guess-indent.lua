-- Auto-detect indentation (tabs vs spaces, indent width) on buffer open.
-- Available config: auto_cmd, override_editorconfig, filetype_exclude, buftype_exclude,
--   on_tab_options, on_space_options (with "detected" for auto tab/shiftwidth)
return {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {}, -- all defaults are fine
}
