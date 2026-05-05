# YAML/K8s Schema Routing

> Route the kubernetes.nvim local schema only to detected K8s manifests via a custom yaml-companion matcher, keep all other YAML files unaffected, and use Snacks as the picker UI for manual schema selection.

## 🎯 Goal

Stop the kubernetes.nvim cluster schema from leaking onto every YAML file. Today the schema is registered with a `*.{yaml,yml}` glob in `yamlls.lua`, so yaml-language-server validates Compose, Helm, GitHub Actions, etc. against the K8s schema in parallel with the correct one — producing false errors like `Property services is not allowed` on `docker-compose.yml`.

Move the routing decision into yaml-companion's matcher pipeline, where it belongs:
- K8s manifests (incl. CRDs) auto-load the local kubernetes.nvim schema.
- All other YAML files stay free of K8s-schema interference.
- Manual schema override via `<leader>ys` / `<leader>yc` / `<leader>yd` runs through Snacks's picker.

## 📋 Requirements

- Detection MUST trigger on any buffer containing both `apiVersion:` and `kind:` lines (covers core resources and CRDs without a hardcoded list).
- Detection MUST NOT trigger on Compose, GitHub Actions, generic config YAML, etc.
- The kubernetes.nvim schema URI (returned ready-formatted as `file://...` by `kubernetes.yamlls_schema()`) MUST replace the builtin yaml-companion matcher's hardcoded GitHub URI.
- The schema MUST appear in `<leader>ys` (`open_ui_select`) under a recognizable name.
- Manual picker overrides MUST take precedence over the auto-matcher (already yaml-companion's default behavior — verify intact).
- yamlls's static `schemas` table MUST NOT register kubernetes.nvim with a wildcard glob anymore.
- Existing pcall workaround for the `schema.lua:99` nil-`result` bug stays in place (separate concern, already applied).
- Snacks's picker MUST become the UI backend for `vim.ui.select` so all yaml-companion pickers render via Snacks.

## 💡 Implementation Ideas

### Approach

yaml-companion ships a builtin K8s matcher at `yaml-companion.builtin.kubernetes` that scans buffer lines for `kind: <known-resource>` against a hardcoded resource list and returns a fixed GitHub-hosted schema URI. We override the loaded matcher's `match` and `handles` functions in `yaml-companion._matchers._loaded.kubernetes` after `setup()` runs:

- `match(bufnr)` — scan lines for `^apiVersion:%s+%S` and `^kind:%s+%S`, return the kubernetes.nvim schema URI when both are found.
- `handles()` — return the kubernetes.nvim schema entry so it shows up in `open_ui_select`.

Why this works: yaml-companion's `context.autodiscover` iterates `_matchers._loaded`, calls `matcher.match(bufnr)`, and calls yaml-companion's own `M.schema()` with the result. `M.schema()` clears any prior schema mapped to the buffer URI before installing the new one, so the picker-override semantics (manual choice wins) stay correct.

We're touching a private module path (`_matchers._loaded`), but it's been stable across yaml-companion versions and the override degrades gracefully — if the API changes, we lose only the override and fall back to the builtin matcher.

The Snacks picker integration is one config flag: `picker.ui_select = true` in `snacks.lua` opts.

### Files to Modify

- `nvim/.config/nvim/lua/plugins/yaml-companion.lua` — add the matcher override block at the end of `config = function()`, after `setup({...})`. The existing pcall wrapper for the schema.lua nil-bug stays untouched.
- `nvim/.config/nvim/lua/config/lsp/servers/yamlls.lua` — remove the kubernetes.nvim schema-with-wildcard-glob block from the `schemas` builder.
- `nvim/.config/nvim/lua/plugins/snacks.lua` — set `picker.ui_select = true` in opts.

No changes needed in `_docs/keybindings.md` — keybindings stay identical, only their picker backend changes.

### Steps

1. Edit `snacks.lua`: add `ui_select = true` inside `opts.picker`.
2. Edit `yamlls.lua`: delete the `pcall(require, "kubernetes")` block that injects the schema with `*.{yaml,yml}` glob.
3. Edit `yaml-companion.lua`: append a matcher-override block inside `config = function()` after `vim.lsp.enable("yamlls")`. The block:
   - `pcall(require, "kubernetes")` — gracefully skip if kubectl missing.
   - Build a `Schema` table `{ name = "Kubernetes (cluster, via kubernetes.nvim)", uri = kubernetes.yamlls_schema() }`. Note: `yamlls_schema()` already returns a `file://...` URI, do not prefix again.
   - Replace `_loaded.kubernetes.match` with a closure that scans for `apiVersion:` and `kind:`.
   - Replace `_loaded.kubernetes.handles` to return our schema.

### Verification (manual, no test framework)

Open a fresh nvim and check:
- `docker-compose.yml` — only compose-spec.json applied (`<leader>yS` shows it), no `services not allowed` errors.
- A Pod / Deployment YAML — `<leader>yS` shows `Kubernetes (cluster, via kubernetes.nvim)`, validation works, hover gives K8s docs.
- A CRD instance (e.g. ArgoCD `Application`) — same as above, validation works against the local schema.
- `<leader>ys` — Snacks picker opens, kubernetes.nvim entry visible by its name.
- `<leader>yc` (in a K8s buffer with cluster reachable) — Snacks picker shows live cluster CRDs.
- Pick a different schema via the picker — only that buffer changes, others unaffected.

## 📦 Dependencies

No new dependencies. Existing setup:

- `mosheavni/yaml-companion.nvim` (commit `15af9354`)
- `diogo464/kubernetes.nvim`
- `folke/snacks.nvim`
- `redhat-developer/yaml-language-server` v1.18.0 (Mason)
- `b0o/schemastore.nvim`

## 🔗 Related

- Upstream bug context for the pcall wrapper: yaml-language-server stack overflow on large K8s schemas → yaml-companion's `schema.lua:99` doesn't guard `nil` `result`. Workaround already applied to `yaml-companion.lua`.
- yaml-companion matcher API: `_matchers/init.lua` (`load_matcher`), `_matchers._loaded[name].match/handles`, called from `context/init.lua:111`.

## 📝 Notes

### Risks

- **Private API**: `_matchers._loaded` is underscore-prefixed and not part of yaml-companion's public surface. Watch for breakage on plugin upgrades; if it changes, fallback is the builtin matcher with the GitHub URI (functional but undesired).
- **False positive detection**: A non-K8s YAML with both `apiVersion:` and `kind:` keys would trigger the matcher. Extremely unlikely in practice; the picker provides an escape hatch.
- **Stale local schema**: kubernetes.nvim caches one cluster's schema at a time. After cluster switch, run `:KubernetesGenerateSchema` once to refresh. Cluster-CRD picker (`<leader>yc`) covers ad-hoc CRDs without regen.
- **Missing `schema.json`**: First-time install before any `:KubernetesGenerateSchema` run — `kubernetes.yamlls_schema()` may return a path that doesn't exist. yamlls silently fails to load it; no crash. Documented quickfix: run `:KubernetesGenerateSchema` once.

### Open questions

None remaining — Snacks `ui_select` confirmed in scope.

## ✅ Done Criteria

- [ ] `snacks.lua` opts include `picker = { ..., ui_select = true }`.
- [ ] `yamlls.lua` no longer registers the kubernetes.nvim schema with a wildcard glob.
- [ ] `yaml-companion.lua` mutates `_loaded.kubernetes.match` and `.handles` to use kubernetes.nvim's local URI.
- [ ] Existing pcall wrapper for `schema.current` remains untouched.
- [ ] Compose file opens with no false K8s-schema diagnostics.
- [ ] K8s manifest opens with `<leader>yS` showing `Kubernetes (cluster, via kubernetes.nvim)`.
- [ ] `<leader>ys` opens through Snacks picker.
- [ ] `<leader>yc` opens through Snacks picker (live cluster CRDs).
- [ ] Manual picker override scoped to single buffer.

---

**Created:** 2026-05-05
**Status:** Planning
**Priority:** Medium
