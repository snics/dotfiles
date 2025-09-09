-- =============================================================================
-- TruffleHog Configuration for none-ls
-- Secret scanner for detecting secrets in code (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "trufflehog",
  meta = {
    url = "https://github.com/trufflesecurity/trufflehog",
    description = "Secret scanner for detecting secrets in code",
  },
  method = DIAGNOSTICS,
  filetypes = {
    "javascript",
    "typescript",
    "python",
    "go",
    "rust",
    "java",
    "yaml",
    "yml",
    "json",
    "toml",
    "ini",
    "env",
    "sh",
    "bash",
    "zsh",
    "fish",
    "powershell",
    "dockerfile",
    "terraform",
    "hcl",
  },
  generator_opts = {
    command = "trufflehog",
    args = { 
      "filesystem", 
      "--no-verification", 
      "--json",
      "$FILENAME"
    },
    to_stdin = false,
    format = "json",
    check_exit_code = function(code)
      -- trufflehog returns 0 on success, 1 on secrets found
      -- Also accept 2 which might be used for some warnings
      return code <= 2
    end,
    on_output = function(params)
      local diagnostics = {}
      
      -- trufflehog outputs structured logs, not JSON arrays
      -- Parse each line as a separate JSON object
      for line in params.output:gmatch("[^\r\n]+") do
        local ok, decoded = pcall(vim.json.decode, line)
        if ok and decoded then
          -- Look for actual secret detection results (not log messages)
          if decoded.detector_name and decoded.raw and decoded.source_metadata then
            local severity = h.diagnostics.severities.error -- Secrets are always high priority
            
            table.insert(diagnostics, {
              row = decoded.source_metadata.data.line or 1,
              col = decoded.source_metadata.data.column or 1,
              end_row = decoded.source_metadata.data.line or 1,
              end_col = (decoded.source_metadata.data.column or 1) + (decoded.raw:len() or 0),
              message = string.format("Secret detected: %s (%s)", decoded.detector_name, decoded.raw),
              severity = severity,
              code = decoded.detector_name,
              source = "trufflehog",
            })
          end
        end
      end
      
      return diagnostics
    end,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Temporarily disabled due to stderr logging issues
    -- trufflehog is better suited for CI/CD batch scanning
    return false
  end,
})
