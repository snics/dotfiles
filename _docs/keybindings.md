# Keybindings Cheatsheet

Unified keyboard shortcut reference across all tools in this dotfiles setup.

**Design principle:** `hjkl` for direction, `|/-` for splits, `z` for zoom — consistent across all layers.

**Modifier strategy:**

| Layer | Modifier | Why |
|-------|----------|-----|
| Ghostty (terminal) | `Ctrl+Shift+` | Avoids conflicts with tmux and CLI tools |
| Tmux (multiplexer) | `Ctrl+Space` prefix | Modern standard, ergonomic |
| Tmux navigation | `Ctrl+` (no prefix) | Seamless with NeoVim via vim-tmux-navigator |
| NeoVim (editor) | `Space` leader | Standard in LazyVim/AstroNvim |
| macOS / Raycast | `Super+` (Cmd) | Kept free, no conflicts |

---

## Ghostty

Split management and tab navigation at the terminal level.

### Splits

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+\` | Vertical split |
| `Ctrl+Shift+-` | Horizontal split |
| `Ctrl+Shift+h/j/k/l` | Navigate splits (left/down/up/right) |
| `Ctrl+Shift+z` | Zoom toggle |
| `Ctrl+Shift+=` | Equalize splits |
| `Ctrl+Shift+w` | Close surface |

### Resize

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+Arrow` | Resize split (10px) |

### Tabs

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+t` | New tab |
| `Ctrl+Shift+]` | Next tab |
| `Ctrl+Shift+[` | Previous tab |

---

## Tmux

Prefix: **`Ctrl+Space`**

### Navigation (no prefix needed)

| Shortcut | Action |
|----------|--------|
| `Ctrl+h/j/k/l` | Navigate panes (tmux-aware, works across NeoVim splits) |

### Splits

| Shortcut | Action |
|----------|--------|
| `Prefix + \|` | Vertical split (in current dir) |
| `Prefix + \` | Vertical split (no shift) |
| `Prefix + -` | Horizontal split (in current dir) |
| `Prefix + c` | New window (in current dir) |

### Resize

| Shortcut | Action |
|----------|--------|
| `Prefix + H/J/K/L` | Resize pane (5px, repeatable) |
| `Prefix + z` | Zoom toggle |

### Copy Mode (Vi)

| Shortcut | Action |
|----------|--------|
| `Prefix + v` | Enter copy mode |
| `v` | Begin selection |
| `V` | Select line |
| `Ctrl+v` | Rectangle selection |
| `y` | Copy to clipboard (pbcopy) |
| `Escape` | Cancel |

### TUI Popups (90% overlay)

| Shortcut | Tool |
|----------|------|
| `Prefix + g` | lazygit |
| `Prefix + y` | yazi (file manager) |
| `Prefix + b` | btop (system monitor) |
| `Prefix + k` | k9s (Kubernetes) |

### Session Management

| Shortcut | Action |
|----------|--------|
| `Prefix + r` | Reload config |
| `Prefix + I` | Install plugins (TPM) |
| `Prefix + U` | Update plugins |

---

## NeoVim

Leader: **`Space`**

### Window Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+h/j/k/l` | Navigate panes (tmux-aware) |
| `Ctrl+Arrow` | Resize window (2px) |

### File & Buffer

| Shortcut | Action |
|----------|--------|
| `Space w` | Save |
| `Space W` | Save and close |
| `Space e` | File explorer (Snacks) |
| `Space ff` | Find files |
| `Space fg` | Git files |
| `Space fr` | Recent files |
| `Space fs` | Grep string |
| `Space fw` | Grep word under cursor |
| `Space fb` | Buffers |
| `]b` / `[b` | Next / previous buffer |
| `Space bd` | Delete buffer |

### Code (LSP)

| Shortcut | Action |
|----------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `Space ca` | Code actions |
| `Space cr` | Rename symbol |
| `Space cd` | Line diagnostics |
| `Space cf` | Format |

### Git

| Shortcut | Action |
|----------|--------|
| `Space gg` | Lazygit |
| `Space gb` | Branches |
| `Space gl` | Log |
| `Space gs` | Status |
| `Space ghs` | Stage hunk |
| `Space ghr` | Reset hunk |
| `Space ghp` | Preview hunk |
| `Space ghb` | Blame line |
| `Space gvv` | Open Diffview |

### Search

| Shortcut | Action |
|----------|--------|
| `Space sg` | Grep |
| `Space sw` | Grep word/selection |
| `Space sr` | Search & Replace (grug-far) |
| `Space sh` | Help pages |
| `Space sk` | Keymaps |
| `Space ss` | LSP Symbols |

### Debug (DAP)

| Shortcut | Action |
|----------|--------|
| `Space db` | Toggle breakpoint |
| `Space dc` | Continue |
| `Space du` | Toggle UI |
| `F5` | Start/Continue |
| `F10` / `F11` / `F12` | Step Over / Into / Out |

### Test (Neotest)

| Shortcut | Action |
|----------|--------|
| `Space tt` | Run nearest test |
| `Space tf` | Run file tests |
| `Space ta` | Run all tests |
| `Space ts` | Toggle summary |

### AI

| Shortcut | Action |
|----------|--------|
| `Space aa` | Toggle chat (CodeCompanion) |
| `Space ap` | Action palette |
| `Space ai` | Inline edit |

### Movement

| Shortcut | Action |
|----------|--------|
| `s` / `S` | Flash jump / treesitter |
| `Alt+j` / `Alt+k` | Move line(s) down / up |
| `jj` / `jk` | Exit insert mode |
| `Ctrl+u` / `Ctrl+d` | Half-page up / down (smooth) |

### Folds (ufo.nvim)

| Shortcut | Action |
|----------|--------|
| `zR` / `zM` | Open / close all folds |
| `zr` / `zm` | Open / close one level |
| `zK` | Peek fold preview |

---

## Zed

Leader: **`Space`** (Vim mode)

### AI / Agents (Space a)

| Shortcut | Action |
|----------|--------|
| `Space a a` | Toggle agent focus |
| `Space a m` | Model selector |
| `Space a M` | Cycle favorite models |
| `Space a p` | Profile selector |
| `Space a P` | Manage profiles |
| `Space a t` | Cycle mode selector |
| `Space a i` | Inline assist |
| `Space a c` | New Claude Code thread |
| `Space a g` | New Gemini CLI thread |
| `Space a x` | New Codex thread |
| `Space a o` | New OpenCode thread |

### Agent Panel

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+z` | Zoom panel |
| `Ctrl+Shift+h` | Increase dock size |
| `Ctrl+Shift+l` | Decrease dock size |
| `Ctrl+Shift+=` | Reset dock size |

### Navigation

| Shortcut | Action |
|----------|--------|
| `Space Space` | File finder |
| `Space ,` | Tab switcher |
| `Space /` | Project search |
| `Space :` | Command palette |
| `Ctrl+h/j/k/l` | Navigate panes |

### Code

| Shortcut | Action |
|----------|--------|
| `Space ca` | Code actions |
| `Space cr` | Rename |
| `Space cd` | Hover |
| `Space cf` | Format |
| `Space cg` | Git blame |

### Git (Space g)

| Shortcut | Action |
|----------|--------|
| `Space gs` | Git panel |
| `Space gb` | Git branch |
| `Space gd` | Toggle diff hunks |
| `Space ghs` | Stage hunk |
| `Space ghr` | Restore hunk |
| `Space ghp` | Preview hunk |

---

## Shell (Zsh)

### FZF

| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | File finder (bat/eza preview) |
| `Alt+C` | Directory changer (eza preview) |
| `Ctrl+/` | Toggle preview (inside fzf) |

### Atuin (History)

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | History search (Atuin) |
| `Up` / `Down` | Prefix search |
| `Ctrl+1..9` | Quick shortcuts |

### Aliases

| Alias | Command |
|-------|---------|
| `vim` / `vi` | nvim |
| `z` / `zi` | zoxide (smart cd) |
| `..` / `...` / `....` | Navigate up 1/2/3 dirs |
| `cl` | clear |
| `dcup` / `dcdown` | docker compose up/down |
| `dclogs` / `dcps` | docker compose logs/ps |

---

## K9s

### Custom Plugin Shortcuts

| Shortcut | Action |
|----------|--------|
| `b` | kubectl-blame |
| `Shift+D` | Debug container |
| `d` | Dive (image inspect) |
| `Shift+E` | Watch events |
| `Ctrl+L` | Raw logs follow |
| `Shift+L` | Logs in less |
| `Shift+T` | Stern multi-pod logs |
| `v` | Helm values |
| `Shift+K` | KRR recommendations |
| `Shift+H` | HolmesGPT troubleshoot |

---

## Cross-Tool Consistency

These bindings use the same key across multiple tools:

| Key | Ghostty | Tmux | NeoVim | Zed |
|-----|---------|------|--------|-----|
| `hjkl` | `Ctrl+Shift+hjkl` navigate | `Ctrl+hjkl` navigate | `Ctrl+hjkl` navigate | `Ctrl+hjkl` navigate |
| `\|` / `-` | `Ctrl+Shift+\` / `-` split | `Prefix+\|` / `-` split | — | — |
| `z` | `Ctrl+Shift+z` zoom | `Prefix+z` zoom | `Space z` zen | `Space z` zen |
| `g` | — | `Prefix+g` lazygit | `Space gg` lazygit | `Space gs` git panel |
| `y` | — | `Prefix+y` yazi | `y` yank | — |
