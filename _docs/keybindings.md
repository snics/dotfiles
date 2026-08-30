# Keybindings Cheatsheet

Unified keyboard shortcut reference across all tools in this dotfiles setup.

**Design principle:** `hjkl` for direction, `|/-` for splits, `z` for zoom — consistent across all layers.

**Modifier strategy:**

| Layer | Modifier | Why |
|-------|----------|-----|
| Ghostty (terminal) | `Ctrl+Shift+` | Avoids conflicts with tmux and CLI tools |
| herdr (agent multiplexer) | `Ctrl+b` prefix | tmux default; `Ctrl+Space` is unusable on macOS+Ghostty (text-input claims it) |
| herdr navigation | `Ctrl+` (no prefix) | Seamless with NeoVim via herdr-splits.nvim |
| Tmux (being phased out) | `Ctrl+Space` prefix | Different from herdr's `Ctrl+b` now — herdr wins inside herdr panes |
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

Ghostty runs as a pure herdr host (`command = herdr-launch`): tabs and
workspaces live in herdr, so Ghostty tab bindings are removed. Each window
gets its own herdr session (`default`, then `ghostty2`, `ghostty3`, …) — see
the herdr Sessions section. Splits stay bound but mirror the window's
session — prefer herdr splits.

---

## Tmux

Prefix: **`Ctrl+Space`** — note this now differs from herdr's `Ctrl+b`.
Inside a herdr pane, herdr's `Ctrl+b` wins; a local tmux keeps `Ctrl+Space`.
Tmux is being phased out.

### Navigation

| Shortcut | Action |
|----------|--------|
| `Prefix + h/j/k/l` | Navigate panes (plain vim-style; vim-tmux-navigator removed with the herdr move) |

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

| Shortcut | Tool | Mnemonik |
|----------|------|----------|
| `Prefix + f` | yazi | **F**iles |
| `Prefix + g` | lazygit | **G**it |
| `Prefix + s` | btop | **S**ystem monitor |
| `Prefix + k` | k9s | **K**ubernetes |

### Session Management

| Shortcut | Action |
|----------|--------|
| `Prefix + r` | Reload config |
| `Prefix + I` | Install plugins (TPM) |
| `Prefix + U` | Update plugins |

---

## herdr

Prefix: **`Ctrl+b`** (tmux default). We wanted `Ctrl+Space` (old tmux muscle
memory) but it is unusable on macOS + Ghostty — the text-input system claims
`Ctrl+Space` and it never reaches Ghostty, so it can't be bound (Ghostty #3403).

### Navigation (no prefix needed)

| Shortcut | Action |
|----------|--------|
| `Ctrl+h/j/k/l` | Navigate panes (herdr-aware, works across NeoVim splits via herdr-splits.nvim) |
| `Alt+Shift+h/j/k/l` | Resize panes (also across the NeoVim/herdr boundary) — on macOS this is the **left** Option key (`macos-option-as-alt = left`); right Option stays compose for ö/ä/ü, `{[]}` etc. Plain `Alt+j/k` stays free for NeoVim move-line. |

### Panes & Tabs

| Shortcut | Action |
|----------|--------|
| `Prefix + \|` | Split right |
| `Prefix + -` | Split down |
| `Prefix + ;` | Jump back to previous pane |
| `Prefix + z` | Zoom pane (fullscreen) |
| `Prefix + x` | Close pane |
| `Prefix + v` | Edit scrollback in editor (like tmux copy mode) |
| `Prefix + c` | New tab |
| `Prefix + 1..9` | Switch tab |
| `Prefix + n` / `p` | Next / previous tab |

### Workspaces & Agents

| Shortcut | Action |
|----------|--------|
| `Cmd+1..9` | Switch workspace directly (no prefix; Ghostty passes these through) |
| `Cmd+Shift+1..9` | Focus agent directly (mirror of workspace switching) |
| `Prefix + [` / `]` | Previous / next workspace (bracket navigation) |
| `Prefix + a` / `Shift+a` | Next / previous agent (attention queue) |
| `Prefix + Shift+n` | New workspace |
| `Prefix + Shift+g` | Worktree picker (sessionizer): local/remote branch or new, opens with layout |
| `Prefix + Shift+o` | Open existing worktree |
| `Prefix + w` | Workspace picker |
| `Prefix + g` | Goto picker (herdr default): tree of workspaces/panes/agents — `/` fuzzy search · `b/w/i/d/a` filter by agent state · `Enter` switch |
| `Prefix + o` | Jump to latest agent notification |
| `Prefix + b` | Toggle sidebar |

### Launchers (tmux muscle memory: letter = function)

yazi/btop/k9s/scratch/herdrctx open as floating popups (tmux display-popup
style) — the tab layout stays untouched. Popups swallow all input (incl.
`Esc` and herdr's own keybindings) until the tool exits. Uniform close key:
**`Ctrl+c`** quits every popup tool (yazi: close-tab-or-quit default; btop/
k9s: native; scratch: on an empty line). `q` (yazi/btop) and `Esc` (scratch,
empty line) work too. NeoVim deliberately opens as a real pane.

| Shortcut | Tool | Mnemonic |
|----------|------|----------|
| `Prefix + f` | yazi (popup 85%) | **F**iles |
| `Cmd+g` | lazygit (popup 90%) | **G**it |
| `Cmd+Shift+r` | tuicr branch review (popup 90%) — merge-base vs. reviewr base list + uncommitted; `q` quits | **R**eview (deep) |
| `Prefix + s` | btop (popup 85%) | **S**ystem monitor |
| `Prefix + k` | k9s (popup 90%) | **K**ubernetes |
| `Prefix + t` | Scratch shell (popup 75%) — `Esc` closes | **T**erminal |
| `Prefix + Shift+s` | herdrctx session overview (popup 70%) — attach needs a detached window | **S**essions |
| `Prefix + e` | NeoVim (in a pane) | **E**dit |
| `Prefix + Shift+e` | Zed (GUI, current dir) | **E**dit (GUI) |

### Sessions (one per Ghostty window)

Every Ghostty window gets its own herdr session via `herdr-launch`
(herdr/.local/bin): the first window attaches `default`, further windows take
`ghostty2`, `ghostty3`, … — detached sessions are re-attached before new ones
are created. Sessions cannot be renamed (no herdr support), so give deliberate
sessions their name at creation time in herdrctx (e.g. `workshop` for
presenting on a second monitor).

| Shortcut | Action |
|----------|--------|
| `Prefix + q` | Detach (agents keep running) — drops the window into herdrctx, the session manager |
| `Prefix + ,` | Settings (macOS convention) |
| `Prefix + Shift+r` | Reload config |
| `Prefix + ?` | Help (all bindings) |

herdrctx keys (after detach): `Enter`/`a` attach · `n` create here / `N`
create with directory picker · `s` stop · `d` delete · `/` search · `q` quit
(closes the window)

### Plugins

| Shortcut | Action |
|----------|--------|
| `Cmd+r` | Toggle reviewr code-review sidebar (auto-opens for new worktrees) — deep pass: `Cmd+Shift+r` tuicr popup |
| `Prefix + Shift+h` | Hunk review of the worktree in a split pane (herdr-hunk-diff) — comments round-trip to the agent |
| `Prefix + Shift+c` | Hunk review of the last commit |
| `Prefix + Shift+i` | Hunk review of staged changes (i = index) |
| `Prefix + Shift+b` | Hunk review of the branch vs its base (b = branch; upstream #15 may pin the base to origin/main) |
| `Prefix + Shift+m` | Send collected Hunk comments to the agent (m = message) |
| `Cmd+o` / `Cmd+Shift+o` | File viewer (overview of agent changes) in split / own tab |
| `Cmd+p` | Project picker (sessionizer) — fuzzy over all repos under ~/Projects, opens with the default layout |
| `Prefix + .` | Quick actions — fuzzy one-off scripts in the current dir |
| `Prefix + u` / `Prefix + Shift+u` | Open a visible URL / file path (termscope, Television popup) |
| `Prefix + y` | Copy-hints (tiny-fingers) — yank a visible token to the clipboard |
| `Prefix + Shift+l` | Manage plugins (herdr-lazy — declarative bundle in `herdr/.config/herdr/plugins.list`, `update herdr` / `just herdr-plugins-update` from the shell) |

---

## NeoVim

Leader: **`Space`**

### Window Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+h/j/k/l` | Navigate panes (herdr-aware via herdr-splits.nvim) |
| `Ctrl+Arrow` | Resize window (2px) |
| `Alt+Shift+h/j/k/l` | Resize across NeoVim/herdr boundary (herdr panes only) |
| `Space \` | Toggle herdr agent float (visual: send selection to agent) |
| `Space ah` / `aH` | herdr agent picker / dashboard (herd.nvim) |

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
| `grt` | Go to type definition (NeoVim 0.12 native) |
| `grx` | Run CodeLens action (NeoVim 0.12 native) |
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
| `Space aC` | Claude Code bridge status (claudecode.nvim; claude runs in a herdr pane, connects via `/ide`) |
| `Space as` | Send selection to Claude Code (visual) |
| `Space ay` / `an` | Accept / deny Claude Code diff |
| `Space ax` | Chat with Codex (ACP via codex-acp, ChatGPT auth, via codecompanion) |
| `Space aw` | Toggle Windsurf Virtual Text |
| `Space aa` | Toggle chat (CodeCompanion) |
| `Space ap` | Action palette |
| `Space ai` | Inline edit |

### Movement

| Shortcut | Action |
|----------|--------|
| `s` / `S` | Flash jump / treesitter (visual `S` = add surround) |
| `Alt+j` / `Alt+k` | Move line(s) down / up |
| `jj` / `jk` | Exit insert mode |
| `Ctrl+u` / `Ctrl+d` | Half-page up / down (smooth) |

### UI Toggles

| Shortcut | Action |
|----------|--------|
| `Space uh` | Toggle inlay hints (enabled by default) |
| `Space uH` | Toggle colorizer |
| `Space ua` | Toggle animations |

### Folds (ufo.nvim)

| Shortcut | Action |
|----------|--------|
| `zR` / `zM` | Open / close all folds |
| `zr` / `zm` | Open / close one level |
| `zK` | Peek fold preview |

### Treesitter Selection (visual mode, NeoVim 0.12 native)

> `an` is now the native treesitter node textobject. The "around number" textobject has been remapped to `aN`.

| Shortcut | Action |
|----------|--------|
| `van` | Expand treesitter selection (around node) |
| `vin` | Shrink treesitter selection (inner node) |
| `v]n` | Select next sibling node |
| `v[n` | Select previous sibling node |
| `Ctrl+Enter` | Expand treesitter selection (alias for `van`) |
| `Ctrl+Backspace` | Shrink treesitter selection (alias for `vin`) |
| `vaN` | Around number (textobject, remapped from `an`) |

### Session / Quit

| Shortcut | Action |
|----------|--------|
| `Space qr` | Restart NeoVim (`:restart`, NeoVim 0.12) |

### Undo

| Shortcut | Action |
|----------|--------|
| `Space sU` | Undo tree (`:Undotree`, NeoVim 0.12 native) |

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
| `Space Space` | File finder (with preview, v1.9) |
| `Space ,` | Tab switcher |
| `Space /` | Live grep — Text Finder (with preview, v1.9) |
| `Space :` | Command palette |
| `Ctrl+h/j/k/l` | Navigate panes |
| `Cmd+Alt+p` | Toggle picker preview (in file/text finder) |
| `Cmd+Alt+→/↓/↑` | Move preview right / below / hide |

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

### FZF & Atuin

| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | File finder (bat/eza preview) |
| `Ctrl+R` | History search (Atuin) |
| `Alt+C` | Directory changer (eza preview) |
| `Ctrl+/` | Toggle preview (inside fzf) |
| `Up` / `Down` | Prefix search (Atuin) |
| `Ctrl+1..9` | Quick shortcuts (Atuin) |

### TUI Launchers (same keys as tmux popups)

| Shortcut | Tool | Mnemonik |
|----------|------|----------|
| `Alt+F` | yazi | **F**iles |
| `Alt+G` | lazygit | **G**it |
| `Alt+S` | btop | **S**ystem monitor |
| `Alt+K` | k9s | **K**ubernetes |

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

### Flux (GitOps) Plugin Shortcuts

Scoped to Flux resources ([derailed/k9s flux.yaml](https://github.com/derailed/k9s/blob/master/plugins/flux.yaml)).

| Shortcut | Scope | Action |
|----------|-------|--------|
| `Shift+T` | HelmRelease, Kustomization, ResourceSet, InputProvider, FluxInstance | Toggle suspend/resume |
| `Shift+R` | GitRepository, HelmRelease, Kustomization, ImageRepository, ImageUpdateAutomation, ResourceSet, InputProvider, FluxInstance | Flux reconcile |
| `Shift+Z` | HelmRepository, OCIRepository | Flux reconcile source |
| `Shift+S` | HelmRelease, Kustomization | List suspended resources |
| `Shift+F` | all | Flux trace (remapped from upstream `Shift+Q` to avoid clash with HolmesGPT) |

---

## Hunk

Review-first diff viewer (`hunk diff` / `hunk show`, `git hd` / `git hs`).
Defaults plus three custom bindings; remappable via `[keybindings]` in
`hunk/.config/hunk/config.toml`. Mouse works everywhere in parallel.

### Navigation

| Shortcut | Action |
|----------|--------|
| `j` / `k` | Scroll one row |
| `d` / `u` | Half page down/up |
| `g` / `G` | Jump to start / end |
| `[` / `]` | Previous / next hunk |
| `{` / `}` | Previous / next annotated hunk |
| `(` / `)` | Previous / next annotated file (custom) |
| `,` / `.` | Previous / next file |
| `Z` | Center current line, vim `zz` (custom) |
| `/` | Focus file filter |
| `Tab` | Switch focus files ↔ filter |

### View

| Shortcut | Action |
|----------|--------|
| `0` / `1` / `2` | Auto / split / stack layout |
| `s` | Toggle files pane |
| `a` | Toggle agent notes |
| `l` / `w` / `m` / `M` | Line numbers / wrap / hunk headers / menu bar |
| `t` | Theme selector |
| `z` | Expand/collapse selected context |

### Actions

| Shortcut | Action |
|----------|--------|
| `c` | Add review note |
| `e` | Open selected file in `$EDITOR` (nvim jumps to line) |
| `r` | Refresh review |
| `?` / `q` | Help / quit |

---

## Cross-Tool Consistency

These bindings use the same key across all layers. Letters map to **function**,
not tool name (`f` = files, `g` = git, `s` = system, `k` = kubernetes).

| Key | Shell (Zsh) | Tmux | herdr | Ghostty | NeoVim | Zed |
|-----|-------------|------|-------|---------|--------|-----|
| `hjkl` | — | `Ctrl+hjkl` navigate | `Ctrl+hjkl` navigate | `Ctrl+Shift+hjkl` navigate | `Ctrl+hjkl` navigate | `Ctrl+hjkl` navigate |
| `\|` / `-` | — | `Prefix+\|` / `-` split | `Prefix+\|` / `-` split | `Ctrl+Shift+\` / `-` split | — | — |
| `z` | — | `Prefix+z` zoom | `Prefix+z` zoom | `Ctrl+Shift+z` zoom | `Space z` zen | `Space z` zen |
| `f` | `Alt+F` yazi | `Prefix+f` yazi | `Prefix+f` yazi | — | `Space ff` find files | `Space Space` file finder |
| `g` | `Alt+G` lazygit | `Prefix+g` lazygit | `Cmd+g` lazygit popup (`Prefix+g` = goto picker) | — | `Space gg` lazygit | `Space gs` git panel |
| `s` | `Alt+S` btop | `Prefix+s` btop | `Prefix+s` btop | — | — | — |
| `k` | `Alt+K` k9s | `Prefix+k` k9s | `Prefix+k` k9s | — | — | — |
