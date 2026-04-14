# HIGH Priority Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 5 high-priority issues: Docker NeoVim 0.12 update, Docker build reliability, Justfile/Makefile sync, lint coverage, and VM test error handling.

**Architecture:** Five independent fixes, ordered from simplest to most complex. Each can be committed and verified independently.

**Tech Stack:** Dockerfile, Bash, Just, Make, ShellCheck

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `justfile:324-325` | Modify | Add `help` recipe + `_test/*.sh` to lint |
| `Makefile:274-275` | Modify | Add `_test/*.sh` to lint |
| `_test/vm-test-macos.sh:143,163` | Modify | Don't mask Homebrew install failure |
| `_images/nvim/Dockerfile` | Modify | Bump NeoVim 0.12.1, add tree-sitter-cli, fix sed patches, add verification |
| `_images/devenv/Dockerfile` | Modify | No changes needed (inherits from snic/nvim) |

---

### Task 1: Add `help` Recipe to Justfile

**Files:**
- Modify: `justfile` (append at end, before or after VM testing section)

- [ ] **Step 1: Add help recipe**

Append at the very end of `justfile`:

```just
# ── Help ───────────────────────────────────────────────

# Show available recipes
help:
    @just --list
```

- [ ] **Step 2: Verify both show identical targets**

```bash
diff <(just help 2>&1 | tail -n +2 | awk '{print $1}' | sort) <(make help 2>&1 | awk '{print $1}' | sort) && echo "OK: targets in sync" || echo "DIFF found (expected: help format differs, targets should match)"
```

- [ ] **Step 3: Commit**

```bash
git add justfile
git commit -m "🐛 fix: add missing help recipe to justfile (sync with Makefile)"
```

---

### Task 2: Extend Lint Coverage to `_test/*.sh`

**Files:**
- Modify: `justfile:324-325`
- Modify: `Makefile:274-275`

- [ ] **Step 1: Add `_test/*.sh` to justfile lint**

In `justfile`, find:
```just
lint:
    shellcheck _install/*.sh _macOS/*.sh _lib/*.sh bootstrap.sh install.sh
```

Replace with:
```just
lint:
    shellcheck _install/*.sh _macOS/*.sh _lib/*.sh _test/*.sh bootstrap.sh install.sh
```

- [ ] **Step 2: Add `_test/*.sh` to Makefile lint**

In `Makefile`, find:
```makefile
lint: ## Lint shell scripts
	shellcheck _install/*.sh _macOS/*.sh _lib/*.sh bootstrap.sh install.sh
```

Replace with:
```makefile
lint: ## Lint shell scripts
	shellcheck _install/*.sh _macOS/*.sh _lib/*.sh _test/*.sh bootstrap.sh install.sh
```

- [ ] **Step 3: Run lint and check output**

```bash
just lint 2>&1 | head -20
```

Expected: ShellCheck may report warnings in `_test/*.sh` (known from Codex audit: `SSH_OPTS` should be array in `vm-test-macos.sh:98`). These are warnings, not errors — the lint target itself should succeed.

- [ ] **Step 4: Commit**

```bash
git add justfile Makefile
git commit -m "🐛 fix: include _test/*.sh in shellcheck lint targets"
```

---

### Task 3: Fix macOS VM Test — Don't Mask Homebrew Install Failure

**Files:**
- Modify: `_test/vm-test-macos.sh:143`

- [ ] **Step 1: Fix Homebrew install error handling**

In `_test/vm-test-macos.sh`, find line 143:
```bash
ssh_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' || true
```

Replace with:
```bash
ssh_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' || {
  echo "FATAL: Homebrew installation failed — cannot continue"
  cleanup
  exit 1
}
```

- [ ] **Step 2: Verify the script still parses**

```bash
bash -n _test/vm-test-macos.sh && echo "OK: script parses"
```
Expected: `OK: script parses`

- [ ] **Step 3: Commit**

```bash
git add _test/vm-test-macos.sh
git commit -m "🐛 fix(test): fail macOS VM test on Homebrew install failure"
```

---

### Task 4: Update nvim Dockerfile for NeoVim 0.12.1

This is the largest task. The Dockerfile needs multiple coordinated changes.

**Files:**
- Modify: `_images/nvim/Dockerfile`

- [ ] **Step 1: Bump NeoVim version and checksums**

In `_images/nvim/Dockerfile`, replace lines 13-19:

Old:
```dockerfile
ARG NVIM_VERSION=0.11.6
ARG GO_VERSION=1.22.5
# SHA256 checksums for binary downloads (supply-chain integrity)
ARG GO_SHA256_AMD64=904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0
ARG GO_SHA256_ARM64=8d21325bfcf431be3660527c1a39d3d9ad71535fabdf5041c826e44e31642b5a
ARG NVIM_SHA256_AMD64=2fc90b962327f73a78afbfb8203fd19db8db9cdf4ee5e2bef84704339add89cc
ARG NVIM_SHA256_ARM64=8ddc0c101846145e830b17bbca50782ca9307eee4fab539d9e2ddaf8793c06f1
```

New:
```dockerfile
ARG NVIM_VERSION=0.12.1
ARG GO_VERSION=1.22.5
# SHA256 checksums for binary downloads (supply-chain integrity)
ARG GO_SHA256_AMD64=904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0
ARG GO_SHA256_ARM64=8d21325bfcf431be3660527c1a39d3d9ad71535fabdf5041c826e44e31642b5a
ARG NVIM_SHA256_AMD64=ab757a1fd9ad307d53d2df4045698906a7ca3993d92260dd8fe49108712d57d0
ARG NVIM_SHA256_ARM64=a3f8aa5590fd2ac930bcc5c9070b9ac1ec33461d262b6428874c5fc640f3f13c
```

- [ ] **Step 2: Add tree-sitter-cli to build dependencies**

In the builder stage `apt-get install` block (line 51-66), add `npm` will already be present. After the `RUN` block that creates the non-root user (line 69-70), add a new step to install tree-sitter-cli:

After line 70 (`&& useradd ...`), add:
```dockerfile

# Install tree-sitter CLI (required by nvim-treesitter main branch to compile parsers)
RUN npm install -g tree-sitter-cli@0.26.8
```

- [ ] **Step 3: Fix sed patches for new treesitter.lua structure**

The treesitter.lua was completely rewritten. The old `sed` patches (lines 99-103) reference code that no longer exists. Replace lines 97-103:

Old:
```dockerfile
# Patch config for Docker: disable update checker and auto-install
# (keeps original dotfiles untouched, plugins are pre-baked in the image)
RUN sed -i 's/enabled = true,/enabled = false,/' ${XDG_CONFIG_HOME}/nvim/lua/config/lazy.lua \
    && sed -i 's/auto_install = true,/auto_install = false,/' ${XDG_CONFIG_HOME}/nvim/lua/plugins/treesitter.lua \
    && sed -i '2i\    cond = false, -- disabled in Docker (needs auth + downloads server)' ${XDG_CONFIG_HOME}/nvim/lua/plugins/windsurf.lua \
    && sed -i 's/mason_tool_installer.setup({/mason_tool_installer.setup({\n            run_on_start = false,/' ${XDG_CONFIG_HOME}/nvim/lua/plugins/mason.lua \
    && sed -i '/cond = function/,/end,/d' ${XDG_CONFIG_HOME}/nvim/lua/plugins/kubernetes.lua
```

New:
```dockerfile
# Patch config for Docker: disable update checker, skip runtime installs
# (keeps original dotfiles untouched, plugins are pre-baked in the image)
RUN sed -i 's/enabled = true,/enabled = false,/' ${XDG_CONFIG_HOME}/nvim/lua/config/lazy.lua \
    && sed -i '2i\    cond = false, -- disabled in Docker (needs auth + downloads server)' ${XDG_CONFIG_HOME}/nvim/lua/plugins/windsurf.lua \
    && sed -i 's/mason_tool_installer.setup({/mason_tool_installer.setup({\n            run_on_start = false,/' ${XDG_CONFIG_HOME}/nvim/lua/plugins/mason.lua \
    && sed -i '/cond = function/,/end,/d' ${XDG_CONFIG_HOME}/nvim/lua/plugins/kubernetes.lua
```

(Removed the `auto_install` sed — that option no longer exists in the rewritten treesitter.lua. The new treesitter config uses `require("nvim-treesitter").install()` which runs on startup, which is fine for Docker since parsers get compiled during build.)

- [ ] **Step 4: Fix TSUpdate step — remove `|| true`, add verification**

Replace lines 112-118:

Old:
```dockerfile
# Step 2: Compile Treesitter parsers (55+ languages)
# Plugin is lazy-loaded, so we must load it explicitly first
RUN nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'nvim-treesitter' } })" \
    -c "TSUpdate" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 60000)" 2>&1 \
    || true
```

New:
```dockerfile
# Step 2: Compile Treesitter parsers
# nvim-treesitter main branch auto-installs on startup via config.
# We run headless to trigger the install, then verify critical parsers exist.
RUN nvim --headless \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 120000)" 2>&1 \
    && nvim --headless -c "lua \
    local critical = {'lua','go','rust','typescript','javascript','yaml','json','html','bash','python','dockerfile','markdown'}; \
    local missing = {}; \
    for _, lang in ipairs(critical) do \
    if not pcall(vim.treesitter.language.inspect, lang) then table.insert(missing, lang) end \
    end; \
    if #missing > 0 then \
    print('ERROR: Missing critical parsers: ' .. table.concat(missing, ', ')); \
    os.exit(1); \
    else \
    print('OK: All ' .. #critical .. ' critical parsers installed'); \
    end; \
    os.exit(0)" 2>&1
```

- [ ] **Step 5: Add verification to Mason steps**

Replace the Mason tools step (lines 120-125):

Old:
```dockerfile
# Step 3: Install Mason tools (linters, formatters) — best-effort
RUN nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'mason-tool-installer.nvim' } })" \
    -c "MasonToolsInstallSync" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 120000)" 2>&1 \
    || echo "Warning: Some Mason tools may have failed to install"
```

New:
```dockerfile
# Step 3: Install Mason tools (linters, formatters)
RUN nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'mason-tool-installer.nvim' } })" \
    -c "MasonToolsInstallSync" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 120000)" 2>&1 \
    || { echo "ERROR: Mason tools installation failed"; exit 1; }
```

Also replace the Mason LSP step ending (line 161):

Old:
```dockerfile
    || echo "Warning: Some Mason LSP servers may have failed to install"
```

New:
```dockerfile
    || { echo "ERROR: Mason LSP server installation failed"; exit 1; }
```

- [ ] **Step 6: Verify Dockerfile syntax**

```bash
docker run --rm -i hadolint/hadolint < _images/nvim/Dockerfile 2>&1 | head -20
```

Or if hadolint is not available as Docker image:
```bash
hadolint _images/nvim/Dockerfile 2>&1 | head -20
```

Expected: Only existing DL3008 (pinned versions) warnings, no new errors.

- [ ] **Step 7: Commit**

```bash
git add _images/nvim/Dockerfile
git commit -m "🔄 chore(docker): bump NeoVim to 0.12.1, add tree-sitter-cli, make builds fail-closed"
```

---

### Task 5: Update TODO List

**Files:**
- Modify: `_planning/TODO.md`

- [ ] **Step 1: Mark completed items**

In `_planning/TODO.md`, change the HIGH section items from `- [ ]` to `- [x]` for the items completed in Tasks 1-4:

```markdown
### Docker Images Rebuild (nach NeoVim 0.12 Migration)
- [x] `_images/nvim/Dockerfile` — nvim-treesitter wechselte von `master` → `main` Branch, braucht jetzt `tree-sitter-cli` zum Kompilieren
- [ ] `_images/devenv/Dockerfile` — gleicher Treesitter-Impact + neue Plugins (kustomize.nvim, kubeconform source)
- [ ] `_images/devenv-web-terminal/Dockerfile` — basiert auf devenv, Rebuild nötig
- [x] Docker Builds sind nicht fail-closed: Homebrew-Fehler werden gesammelt aber nicht abgebrochen (nvim Dockerfile Zeile 114: `TSUpdate || true`, Mason best-effort)
- [ ] Smoke Tests nach Rebuild verifizieren

### Justfile/Makefile Sync
- [x] `help` Target fehlt im Justfile (Makefile hat es, verletzt CLAUDE.md Sync-Regel)

### Lint Coverage
- [x] `just lint` / `make lint` prüfen `_test/*.sh` nicht — ShellCheck Findings werden nie exercised

### macOS VM Test
- [x] `_test/vm-test-macos.sh` Zeile 143-144: fehlgeschlagene Homebrew-Installs werden maskiert
```

Note: devenv/devenv-web-terminal Dockerfiles and smoke tests remain unchecked — they need an actual Docker build to verify, which requires Docker running.

- [ ] **Step 2: Commit**

```bash
git add _planning/TODO.md
git commit -m "📝 docs: update TODO with completed HIGH priority fixes"
```
