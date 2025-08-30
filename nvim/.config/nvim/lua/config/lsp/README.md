# LSP Configuration

Modular LSP configuration for Neovim with comprehensive schema support for JSON and YAML files.

## 📂 Directory Structure

```
lsp/
├── init.lua              # Main LSP entry point
├── servers/              # Individual server configurations
│   ├── jsonls.lua       # JSON Language Server
│   ├── yamlls.lua       # YAML Language Server + Kubernetes
│   ├── lua_ls.lua       # Lua Language Server
│   ├── gopls.lua        # Go Language Server
│   └── graphql.lua      # GraphQL Language Server
├── docs/                # Documentation
├── .cursor/rules        # Cursor AI configuration
└── AGENTS.md           # OpenCode AI configuration
```

## 🔧 How to Work with This Configuration

### Adding a New LSP Server

1. **Create Server Configuration**
   ```bash
   # Create new server file
   touch servers/python.lua
   ```

2. **Use This Template**
   ```lua
   -- servers/python.lua
   local M = {}

   function M.setup(lspconfig, capabilities)
     lspconfig.pylsp.setup({
       capabilities = capabilities,
       settings = {
         pylsp = {
           plugins = {
             pycodestyle = { enabled = false },
             mccabe = { enabled = false },
             pyflakes = { enabled = false },
             flake8 = { enabled = true },
           },
         },
       },
       filetypes = { "python" },
       root_dir = require("lspconfig/util").root_pattern(
         "pyproject.toml", "setup.py", "setup.cfg", 
         "requirements.txt", "Pipfile", ".git"
       ),
     })
   end

   return M
   ```

3. **Add to Main Configuration**
   ```lua
   -- In init.lua, add this line:
   require("config.lsp.servers.python").setup(lspconfig, M.capabilities)
   ```

4. **Add to Mason Installation**
   ```lua
   -- In plugins/mason.lua, add to ensure_installed:
   "pylsp", -- Python Language Server
   ```

### Modifying Existing Servers

**Edit only the relevant server file:**
- JSON issues → `servers/jsonls.lua`
- YAML/Kubernetes issues → `servers/yamlls.lua`
- Lua issues → `servers/lua_ls.lua`
- Go issues → `servers/gopls.lua`
- GraphQL issues → `servers/graphql.lua`

### Adding Custom Schemas

**For JSON files** (edit `servers/jsonls.lua`):
```lua
-- Extend existing schemas
schemas = vim.tbl_extend("force", 
  require('schemastore').json.schemas(),
  {
    ["https://my-custom-schema.json"] = "my-pattern*.json"
  }
)
```

**For YAML files** (edit `servers/yamlls.lua`):
```lua
-- Add after SchemaStore loading
schemas["https://my-yaml-schema.yaml"] = {
  "my-pattern*.{yaml,yml}",
  "configs/**/*.{yaml,yml}"
}
```

**For Kubernetes resources** (edit `servers/yamlls.lua`):
```lua
-- Add to static patterns section
"*mynewresource*.{yaml,yml}", "*mnr*.{yaml,yml}",
```

## 🛠️ Development Workflow

### 1. Making Changes
```bash
# Edit the relevant server file
nvim servers/jsonls.lua

# Restart Neovim to apply changes
# :qa then reopen nvim
```

### 2. Testing Changes
```vim
:LspInfo                 " Check server status
:messages               " Check for errors
:LspRestart             " Restart servers if needed
```

### 3. Debugging Issues
```vim
# Check file type detection
:lua print(vim.bo.filetype)

# Check schema loading (JSON)
:lua print(vim.inspect(require('schemastore').json.schemas()))

# Check schema loading (YAML)  
:lua print(vim.inspect(require('schemastore').yaml.schemas()))
```

## 🎯 Key Features

### JSON Language Server (`jsonls.lua`)
- **100+ Automatic Schemas** via SchemaStore.nvim
- **Color Previews** for hex/RGB values (`#ff0000` → 🔴)
- **Smart Validation** with real-time error checking
- **Auto-formatting** with customizable options
- **File Types**: `.json`, `.jsonc`, `.json5`

### YAML Language Server (`yamlls.lua`)
- **SchemaStore Integration** for 100+ YAML schemas
- **Dynamic Kubernetes Support** via kubernetes.nvim
- **Static Kubernetes Fallback** with comprehensive resource patterns
- **Smart Schema Detection** for GitHub Actions, Docker Compose, Helm, etc.
- **File Types**: `.yaml`, `.yml`, `.yaml.docker-compose`, etc.

## 📋 Common Tasks

### Performance Optimization
```lua
-- In any server file, adjust these settings:
settings = {
  [language] = {
    maxItemsComputed = 1000,        -- Reduce for performance
    colorDecorators = { enable = false }, -- Disable expensive features
    hover = { enable = false },     -- Disable if not needed
  }
}
```

### File Pattern Troubleshooting
If autocompletion doesn't work, check if your file name matches the patterns:

**Kubernetes files that work:**
- `my-app-deployment.yaml` ✅
- `service.yml` ✅  
- `nginx-pod.yaml` ✅
- `configmap-prod.yml` ✅
- `k8s/resources.yaml` ✅

**Files that don't match patterns:**
- `my-app.yaml` ❌ (generic name, no resource indicator)

## 🔄 Maintenance

### Regular Updates
```vim
# Update schemas automatically
:Lazy update schemastore.nvim

# Update Kubernetes schemas  
:Lazy update kubernetes.nvim
```

### Backup Configuration
```bash
# Your entire LSP config is in this directory
cp -r lsp/ ~/backup/lsp-config-backup/
```

## 🎯 Success Indicators

A working configuration should provide:
- ✅ Autocompletion in JSON/YAML files
- ✅ Schema validation errors for invalid syntax
- ✅ Hover documentation on properties
- ✅ Color previews in JSON files (if enabled)
- ✅ YAML path display in status line
- ✅ No LSP errors in `:messages`

## 📚 Need More Help?

- **Setup Instructions**: `docs/setup-guide.md`
- **AI Integration**: `.cursor/rules` and `AGENTS.md`
- **Detailed Documentation**: `docs/` directory

---

**Compatible with**: Neovim 0.9+, lazy.nvim  
**Last Updated**: January 2025