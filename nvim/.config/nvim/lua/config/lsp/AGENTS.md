# LSP Configuration Agents

AI agent instructions for working with this modular LSP configuration.

## 🎯 Project Overview

This is a **modular LSP configuration** for Neovim with comprehensive schema support for JSON and YAML files. The architecture prioritizes maintainability, performance, and extensibility.

### Key Principles
- **Modular Design**: Each language server has its own configuration file
- **Schema-First Approach**: Automatic schema detection for 100+ file types
- **Performance Optimized**: Tuned for large files and complex projects
- **Fallback Strategies**: Multiple layers of schema detection (dynamic → static → default)

## 📂 Architecture Understanding

```
config/lsp/
├── init.lua              # 🚀 Orchestrator - loads all servers
├── servers/              # 🔧 Individual server configurations
│   ├── jsonls.lua       # JSON + SchemaStore + Color previews
│   ├── yamlls.lua       # YAML + Kubernetes + SchemaStore
│   ├── lua_ls.lua       # Lua + Neovim optimization
│   ├── gopls.lua        # Go + Enhanced analysis  
│   └── graphql.lua      # GraphQL + Multi-framework
├── docs/                # 📚 Documentation
├── .cursor/rules        # 🤖 Cursor AI instructions
└── AGENTS.md           # 🤖 AI agent instructions (this file)
```

## 🔧 Core Components

### 1. Schema Integration
- **SchemaStore.nvim**: Provides 100+ automatic schemas for JSON/YAML
- **kubernetes.nvim**: Dynamic Kubernetes schemas from live clusters
- **Static Fallbacks**: Comprehensive patterns for offline development

### 2. Performance Features
- **Adaptive Computing**: `maxItemsComputed` limits for large files
- **Smart Triggers**: Completion activated on `"` and `:` characters
- **Lazy Loading**: Servers only load when needed

### 3. Visual Enhancements
- **Color Decorators**: Live preview of color values in JSON
- **Hover Documentation**: Schema-based contextual help
- **Real-time Validation**: Immediate error feedback

## 🎯 Agent Task Patterns

### Task: "Add support for [language] LSP"

**Process:**
1. **Research**: Check if server exists in Mason registry
2. **Create**: New file `servers/[language].lua` with this template:
   ```lua
   local M = {}
   
   function M.setup(lspconfig, capabilities)
     lspconfig.[server_name].setup({
       capabilities = capabilities,
       settings = {
         [language] = {
           -- Language-specific configuration
         },
       },
       filetypes = { "ext1", "ext2" },
       root_dir = require("lspconfig/util").root_pattern("config_file", ".git"),
     })
   end
   
   return M
   ```
3. **Integrate**: Add to `init.lua`:
   ```lua
   require("config.lsp.servers.[language]").setup(lspconfig, M.capabilities)
   ```
4. **Install**: Add to Mason ensure_installed in `plugins/mason.lua`
5. **Test**: Create test file and verify functionality

### Task: "Fix [filetype] autocompletion not working"

**Diagnostic Process:**
1. **Identify Server**: Determine which server handles the filetype
2. **Check Patterns**: Verify file naming matches schema patterns
3. **Debug Commands**:
   ```vim
   :LspInfo                    " Check server attachment
   :messages                   " Check for errors
   :lua print(vim.bo.filetype) " Verify filetype detection
   ```
4. **Schema Verification**:
   ```lua
   -- For JSON files
   :lua print(vim.inspect(require('schemastore').json.schemas()))
   
   -- For YAML files  
   :lua print(vim.inspect(require('schemastore').yaml.schemas()))
   ```
5. **Apply Fix**: Modify relevant `servers/[name].lua` file

### Task: "Add custom schema for [filetype]"

**For JSON Files** (edit `servers/jsonls.lua`):
```lua
-- Extend existing schemas
schemas = vim.tbl_extend("force", 
  require('schemastore').json.schemas(),
  {
    ["https://my-custom-schema.json"] = "my-pattern*.json"
  }
)
```

**For YAML Files** (edit `servers/yamlls.lua`):
```lua
-- Add after SchemaStore loading
schemas["https://my-yaml-schema.yaml"] = {
  "my-pattern*.{yaml,yml}",
  "configs/**/*.{yaml,yml}"
}
```

**For Kubernetes Resources** (edit `servers/yamlls.lua`):
```lua
-- Add to static patterns section
"*mynewresource*.{yaml,yml}", "*mnr*.{yaml,yml}",
```

### Task: "Optimize performance for large files"

**Performance Tuning Approach:**
1. **Identify Bottleneck**: Which server/language is slow?
2. **Locate Config**: Find relevant `servers/[name].lua` file
3. **Apply Optimizations**:
   ```lua
   settings = {
     [language] = {
       maxItemsComputed = 1000,        -- Reduce from 5000
       colorDecorators = { enable = false }, -- Disable expensive features
       hover = { enable = false },     -- Disable if not needed
     }
   }
   ```
4. **Adaptive Configuration**:
   ```lua
   -- File-size-based configuration
   local file_size = vim.fn.getfsize(vim.fn.expand('%'))
   local max_items = file_size > 100000 and 1000 or 5000
   ```

## 🔍 Schema Resolution Logic

### JSON Schema Flow
```
File Detection → SchemaStore Lookup → Pattern Matching → Schema Application
     ↓                    ↓                  ↓               ↓
package.json → NPM Schema → "package.json" → Validation + Completion
```

### YAML Schema Flow  
```
File Detection → SchemaStore Scan → Kubernetes Check → Pattern Match → Schema Application
     ↓               ↓                    ↓              ↓              ↓
deployment.yaml → Standard YAML → kubernetes.nvim? → "*deployment*" → K8s Schema
```

### Kubernetes Strategy
1. **Primary**: Dynamic schema from `kubernetes.nvim` (requires cluster)
2. **Fallback**: Static patterns covering 50+ resource types
3. **Patterns**: Support prefix/suffix matching (e.g., `my-app-pod.yaml`)

## 📋 File Pattern References

### JSON (Auto-detected via SchemaStore)
- `package.json` → NPM Package Schema
- `tsconfig.json` → TypeScript Configuration
- `.eslintrc.json` → ESLint Configuration
- `composer.json` → PHP Composer Schema

### YAML (Pattern-based)
- `*deployment*.yaml` → Kubernetes Deployment Schema
- `docker-compose*.yml` → Docker Compose Schema
- `.github/workflows/*.yml` → GitHub Actions Schema
- `Chart.yaml` → Helm Chart Schema

### Kubernetes Resources (Comprehensive)
- Workloads: `*pod*.yaml`, `*deployment*.yaml`, `*service*.yaml`
- Config: `*configmap*.yaml`, `*secret*.yaml`
- Network: `*ingress*.yaml`, `*networkpolicy*.yaml`
- Security: `*role*.yaml`, `*serviceaccount*.yaml`
- Storage: `*pv*.yaml`, `*pvc*.yaml`, `*storageclass*.yaml`

## 🚨 Critical Guidelines

### Always Do
- **Test changes** with files in `test-schemas/` directory
- **Preserve modularity** - edit only relevant server files
- **Maintain schema coverage** - don't break existing functionality
- **Update documentation** when adding new capabilities

### Never Do
- **Create monolithic configs** - keep servers separated
- **Break SchemaStore integration** without providing alternatives
- **Modify multiple server files** for single-language changes
- **Remove fallback patterns** without replacement

## 🔄 Testing Protocol

### After Making Changes
1. **Restart Neovim**: `:qa` then reopen
2. **Check LSP Status**: `:LspInfo`
3. **Test Completion**: Open relevant test files
4. **Verify Schemas**: Check `:messages` for loading confirmations
5. **Performance Test**: Try with large files if applicable

### Test Files Available
- `test-schemas/package.json` → JSON schema testing
- `test-schemas/deployment.yaml` → Kubernetes schema testing  
- `test-schemas/ci.yml` → GitHub Actions schema testing

## 🎯 Success Metrics

A properly functioning configuration should provide:
- ✅ **Autocompletion** in JSON/YAML files
- ✅ **Schema validation** with error highlighting
- ✅ **Hover documentation** from schemas
- ✅ **Color previews** in JSON files
- ✅ **YAML path display** in status line
- ✅ **No LSP errors** in `:messages`

## 📞 User Communication

When interacting with users:
1. **Ask specific questions**: What file type? What exact behavior expected?
2. **Provide debugging steps**: Clear `:LspInfo` and `:messages` instructions
3. **Give test examples**: Show how to verify fixes work
4. **Explain reasoning**: Why specific changes solve the problem
5. **Document changes**: Update relevant documentation files

This modular approach ensures maintainability while providing comprehensive language support for modern development workflows.