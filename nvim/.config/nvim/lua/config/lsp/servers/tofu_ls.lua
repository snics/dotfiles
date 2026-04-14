-- tofu_ls — OpenTofu Language Server
-- Mason installs the binary, but nvim-lspconfig has no default config yet.
-- Manual config with filetypes and root markers.

local M = {}

M.config = {
    cmd = { "tofu-ls", "serve" },
    filetypes = { "opentofu", "opentofu-vars", "terraform", "terraform-vars" },
    root_markers = { ".terraform", "main.tf", "terraform.tf", "opentofu.tf" },
}

return M
