# Neovim Keymapping Reference

Complete reference of all keybindings after the refactoring migration.
Leader key: `<Space>`

---

## Legend

| Symbol | Meaning |
|--------|---------|
| `n` | Normal mode |
| `v` | Visual mode |
| `i` | Insert mode |
| `o` | Operator-pending mode |
| `x` | Visual + Select mode |
| `c` | Command-line mode |
| `t` | Terminal mode |
| `s` | Select mode |
| `ft=X` | Only active in filetype X |
| `(buffer)` | Buffer-local, set on attach |

---

## Visual Keymap Tree

Complete tree of all keybindings. Mode shown on the right when not normal mode only.

### Leader Key Tree — `<Space>`

```
<Space> ·································· which-key popup
│
├── Instant Actions (no submenu)
│   ├── w   󰆓  Save file
│   ├── W   󰗼  Save and close
│   ├── e   󰙅  File Explorer
│   ├── n   󰂚  Notification History
│   ├── N   󰎟  Neovim News
│   ├── z   󰅺  Zen Mode
│   ├── Z   󰁌  Zoom
│   ├── .   󰟃  Scratch Buffer
│   ├── S   󰟃  Select Scratch Buffer
│   ├── ␣   󰈞  Smart Find Files
│   ├── ,   󰈔  Buffers
│   ├── /   󰑑  Grep
│   ├── :   󰘳  Command History
│   ├── +   󰐕  Increment number
│   └── -   󰍴  Decrement number
│
├── 󰚩 a  AI
│   ├── a   Toggle chat
│   ├── A   New chat
│   ├── p   Action palette                        n,v
│   ├── i   Inline edit                            n,v
│   ├── e   Explain code                             v
│   ├── f   Fix code                                 v
│   ├── t   Generate tests                           v
│   ├── r   Review code                              v
│   ├── d   Document code
│   ├── c   Commit message
│   ├── v   Toggle virtual text
│   ├── V   Virtual text ON
│   └── x   Virtual text OFF
│
├── 󰈔 b  Buffer
│   ├── d   Delete buffer
│   ├── o   Delete other buffers
│   └── p   Pick buffer
│
├── 󰌵 c  Code
│   ├── a   Code actions                           n,v
│   ├── r   Rename symbol
│   ├── R   Rename file
│   ├── d   Line diagnostics
│   ├── D   Toggle diagnostics
│   └── f   Format file/range                      n,v
│
├── 󰃤 d  Debug
│   ├── b   Toggle breakpoint
│   ├── B   Conditional breakpoint
│   ├── c   Continue
│   ├── r   Open REPL
│   ├── l   Run last
│   ├── h   Hover variables
│   ├── p   Preview
│   ├── f   Frames
│   ├── s   Scopes
│   ├── q   Quit debug
│   ├── u   Toggle UI
│   └── e   Eval                                   n,v
│
├── 󰈞 f  Find
│   ├── f   Find files
│   ├── g   Git files
│   ├── r   Recent files
│   ├── s   Find string (grep)
│   ├── w   Find word under cursor
│   ├── c   Config files
│   ├── b   Buffers
│   ├── p   Projects
│   └── t   Todos
│
├──  g  Git
│   ├── g   Lazygit
│   ├── b   Branches
│   ├── l   Log
│   ├── L   Log (current line)
│   ├── s   Status
│   ├── S   Stash
│   ├── d   Diff
│   ├── f   Log file
│   ├── B   Git Browse                             n,v
│   ├── 󰊢 h  Hunks
│   │   ├── s   Stage hunk                         n,v
│   │   ├── r   Reset hunk                         n,v
│   │   ├── S   Stage buffer
│   │   ├── R   Reset buffer
│   │   ├── u   Undo stage
│   │   ├── p   Preview hunk
│   │   ├── i   Preview inline
│   │   ├── b   Blame line
│   │   ├── B   Toggle blame
│   │   ├── d   Diff this
│   │   ├── D   Diff this ~
│   │   ├── q   Hunks to quickfix
│   │   └── Q   All hunks to quickfix
│   └── 󰦓 v  Diffview
│       ├── v   Open diffview
│       ├── x   Close diffview
│       ├── h   File history
│       └── H   Branch history
│
├── 󰒕 l  LSP/Lint
│   ├── d   Toggle diagnostics
│   ├── D   Diagnostics float
│   ├── c   Clear diagnostics
│   ├── l   Open none-ls log
│   ├── i   Show none-ls info
│   └── s   Restart LSP
│
├──  m  Markdown                               ft=md
│   ├── p   Toggle browser preview
│   └── r   Toggle render-markdown
│
├── 󰗼 q  Quit
│   ├── q   Close buffer
│   └── Q   Force close (discard changes)
│
├── 󰣪 r  Refactor
│   ├── r   Select refactor                        n,x
│   ├── e   Extract Function                         x
│   ├── f   Extract Function To File                 x
│   ├── v   Extract Variable                         x
│   ├── i   Inline Variable                        n,x
│   ├── I   Inline Function
│   ├── b   Extract Block
│   │   └── f   Extract Block To File
│   ├── p   Debug Print Variable                   n,x
│   ├── P   Debug Printf
│   └── c   Debug Cleanup
│
├── 󰍉 s  Search
│   ├── b   Buffer Lines
│   ├── B   Grep Open Buffers
│   ├── g   Grep
│   ├── w   Grep word/selection                    n,x
│   ├── r   Search & Replace
│   ├── R   Search & Replace (file)
│   ├── "   Registers
│   ├── /   Search History
│   ├── a   Autocmds
│   ├── c   Command History
│   ├── C   Commands
│   ├── d   Diagnostics
│   ├── D   Buffer Diagnostics
│   ├── h   Help Pages
│   ├── H   Highlights
│   ├── i   Icons
│   ├── j   Jumps
│   ├── k   Keymaps
│   ├── l   Location List
│   ├── m   Marks
│   ├── M   Man Pages
│   ├── p   Plugin Spec
│   ├── P   Resume last picker
│   ├── q   Quickfix List
│   ├── s   LSP Symbols
│   ├── S   LSP Workspace Symbols
│   ├── t   Todo Comments
│   ├── T   Todo/Fix/Fixme
│   └── u   Undo History
│
├── 󰙨 t  Test
│   ├── t   Run nearest test
│   ├── f   Run file tests
│   ├── a   Run all tests
│   ├── s   Toggle summary
│   ├── o   Show output
│   ├── p   Output panel
│   ├── d   Debug test
│   ├── S   Stop
│   └── l   Re-run last
│
├── 󰓩 ⇥  Tabs
│   ├── ⇥   Open new tab
│   ├── x   Close tab  (also: d)
│   ├── ]   Next tab   (also: n)
│   ├── [   Prev tab   (also: p)
│   └── f   Buffer to new tab
│
├── 󰙵 u  UI Toggles
│   ├── s   Toggle spelling
│   ├── w   Toggle word wrap
│   ├── L   Toggle relative numbers
│   ├── l   Toggle line numbers
│   ├── d   Toggle dim inactive
│   ├── c   Toggle conceal
│   ├── T   Toggle treesitter highlight
│   ├── b   Toggle dark/light background
│   ├── h   Toggle inlay hints
│   ├── g   Toggle indent guides
│   ├── D   Toggle diagnostics
│   ├── n   Dismiss notifications
│   ├── C   Colorschemes (picker)
│   ├── x   Toggle treesitter context
│   ├── H   Toggle colorizer
│   └── a   Toggle animations
│
├── 󰆓 w  Save + Session
│   │       w alone = Save (:w)
│   ├── r   Restore session
│   ├── s   Save session
│   ├── d   Delete session
│   └── f   Find sessions
│
├── 󰔫 x  Trouble
│   ├── w   Workspace diagnostics
│   ├── d   Document diagnostics
│   ├── q   Quickfix list
│   ├── l   Location list
│   ├── t   Todos
│   ├── s   Symbols outline
│   └── L   LSP references panel
│
├──  y  YAML/K8s                               ft=yaml
│   ├── v   Show path + value
│   ├── y   Yank path + value
│   ├── k   Yank key
│   ├── V   Yank value
│   ├── q   Quickfix (paths)
│   ├── h   Remove highlight
│   ├── p   Path picker
│   ├── s   Select schema
│   ├── S   Show current schema
│   ├── d   Browse Datree CRDs
│   ├── c   Browse cluster CRDs
│   ├── m   Add CRD modelines
│   ├── Q   Keys to quickfix
│   └── K   Regenerate K8s schema
│
├── 󰅺 z  Zen Mode                                 instant
└── 󰁌 Z  Zoom                                     instant
```

### Language-Specific Trees (only visible in matching filetype)

```
<Space> G   Go                                    ft=go
├── 󰓹 t  Tags
│   ├── j   Add json tags
│   ├── y   Add yaml tags
│   ├── x   Add xml tags
│   ├── r   Remove tags
│   ├── a   Generate test (func)
│   ├── A   Generate test (all)
│   └── e   Generate test (exported)
├── 󰏗 m  Module
│   ├── t   go mod tidy
│   ├── i   go mod init
│   └── g   go mod get
├── 󰐊 i  Generate
│   ├── i   Implement interface
│   └── e   Generate if err
├── c   Doc comment
├── g   go generate
└── G   go generate (file)

<Space> R   Rust                                  ft=rust
├── e   Expand macro
├── c   Open Cargo.toml
├── p   Parent module
├── d   Render diagnostic
├── r   Runnables
├── D   Debuggables
├── j   Join lines
├── a   Code action
└──  c  Crates                                ft=toml
    ├── u   Upgrade all crates
    ├── i   Crate info
    ├── v   Crate versions
    ├── f   Crate features
    └── d   Crate dependencies
```

### Non-Leader Trees

```
g ····························· Goto / LSP
├── d   Go to definition
├── D   Go to declaration
├── r   Find references
├── I   Go to implementation
├── y   Go to type definition
├── 󰆉 c  Comment
│   ├── c   Toggle line comment
│   ├── o   Add comment below
│   ├── O   Add comment above
│   └── A   Add comment at end of line
└── bc  Toggle block comment

K ····························· Hover documentation

] ····························· Next
├── d   Next diagnostic
├── h   Next git hunk
├── t   Next TODO comment
├── T   Next failed test
├── b   Next buffer
├── q   Next quickfix
├── e   Next error
├── w   Next warning
├── m   Next function start
├── M   Next function end
├── c   Next class start
├── C   Next class end
├── i   Next conditional start
├── I   Next conditional end
├── l   Next loop start
├── L   Next loop end
├── a   Swap parameter next
└── ]   Next word reference

[ ····························· Previous
├── d   Previous diagnostic
├── h   Previous git hunk
├── t   Previous TODO comment
├── T   Previous failed test
├── b   Previous buffer
├── q   Previous quickfix
├── e   Previous error
├── w   Previous warning
├── x   Jump to context
├── m   Previous function start
├── M   Previous function end
├── c   Previous class start
├── C   Previous class end
├── i   Previous conditional start
├── I   Previous conditional end
├── l   Previous loop start
├── L   Previous loop end
├── a   Swap parameter prev
└── [   Previous word reference

z ····························· Folds / View
├── R   Open all folds
├── M   Close all folds
├── r   Open one fold level
├── m   Close one fold level
├── K   Peek fold preview
├── t   Cursor to top (smooth)
├── z   Cursor to center (smooth)
└── b   Cursor to bottom (smooth)

s ····························· Flash jump                n,x,o
S ····························· Flash treesitter           n,x,o
```

### Text Object Tree

```
Operators: d (delete) · c (change) · y (yank) · v (select)

a ····························· Around                    o,x
├── f   Function
├── c   Class
├── a   Parameter
├── i   Conditional
├── l   Loop
├── b   Block
├── C   Function call
├── s   Assignment (key+value)
├── k   Assignment key (left)
├── v   Assignment value (right)
├── n   Number
├── t   Comment
└── S   Statement

i ····························· Inside                    o,x
├── f   Function
├── c   Class
├── a   Parameter
├── i   Conditional
├── l   Loop
├── b   Block
├── C   Function call
├── s   Assignment (value only)
├── t   Comment
└── h   Git hunk
```

### Control Keys

```
Ctrl
├── h/j/k/l   Window navigation                   n,t
├── ↑/↓/←/→   Window resize
├── u / d      Half-page up/down (smooth)
├── b / f      Full page up/down (smooth)
├── y / e      Line up/down (smooth)
├── s          Save file                           i,n,v,s
├── /          Toggle terminal                     n,t
├── p / n      Yank history prev/next
├── Enter      Start/expand selection              n,v
├── Backspace  Shrink selection                      v
└── s          Toggle Flash search                   c

Alt
├── j / k      Move line(s) down/up                n,i,v
├── ] / [      Next/prev Windsurf suggestion         i
└── c          Clear Windsurf suggestion              i

F-keys
├── F5         Debug: Start/Continue
├── F10        Debug: Step Over
├── F11        Debug: Step Into
└── F12        Debug: Step Out

Insert Mode
├── jj / jk    Exit insert mode
├── , . ;      Self + undo breakpoint
├── Tab        Smart: completion → snippet → trigger
├── S-Tab      Smart: prev completion → jump back
├── C-b / C-f  Scroll completion docs
├── C-e        Close completion menu
└── C-l        Accept Windsurf completion
```

---

## 1. Quick Reference Card

The keys you'll use every day. Print this page or keep it open as a tab.

### Essentials

| Key | Action | Remember as... |
|-----|--------|----------------|
| `<Space>` | which-key popup (shows all groups) | "What can I do?" |
| `<Space><Space>` | Smart find files | "Find anything" |
| `<Space>/` | Grep across project | "Search everywhere" |
| `<Space>,` | Switch buffer | "Quick buffer" |
| `<Space>w` | Save file | "Write" |
| `<Space>e` | File explorer | "Explorer" |
| `<Space>qq` | Close buffer | "Quit quit" |
| `<C-s>` | Save file (works in any mode) | Universal save |
| `jj` or `jk` | Exit insert mode | "jj = just joking, back to normal" |
| `<Esc>` | Clear search highlights | |

### Moving Around

| Key | Action | Remember as... |
|-----|--------|----------------|
| `<C-h/j/k/l>` | Move to left/down/up/right window | Like h/j/k/l but for windows |
| `<C-u>` / `<C-d>` | Smooth half-page up/down | |
| `s` | Flash jump (type 2 chars, jump anywhere) | "Seek" |
| `S` | Flash treesitter (select syntax node) | "Seek Syntax" |
| `gd` | Go to definition | "Go Definition" |
| `gr` | Find references | "Go References" |
| `K` | Hover documentation | |
| `[d` / `]d` | Previous/next diagnostic | |
| `[h` / `]h` | Previous/next git hunk | |

### Editing

| Key | Action | Remember as... |
|-----|--------|----------------|
| `<Space>ca` | Code actions (fix, refactor...) | "Code Action" |
| `<Space>cr` | Rename symbol | "Code Rename" |
| `<Space>cf` | Format file | "Code Format" |
| `<A-j>` / `<A-k>` | Move line(s) down/up | |
| `gc` | Toggle comment (motion) | "Go Comment" |
| `gcc` | Toggle comment (current line) | |
| `y` / `p` / `P` | Yank / paste after / paste before | Enhanced by yanky.nvim |
| `<C-p>` / `<C-n>` | Cycle through yank history | |

### Finding Things

| Key | Action | Remember as... |
|-----|--------|----------------|
| `<Space>ff` | Find files | "Find Files" |
| `<Space>fg` | Find git files | "Find Git" |
| `<Space>fr` | Find recent files | "Find Recent" |
| `<Space>fs` | Find string (grep) | "Find String" |
| `<Space>fw` | Find word under cursor | "Find Word" |
| `<Space>sh` | Search help pages | "Search Help" |
| `<Space>sk` | Search keymaps | "Search Keymaps" |
| `<Space>sd` | Search diagnostics | "Search Diagnostics" |

---

## 2. Leader Key Groups

Press `<Space>` and wait — which-key shows all available groups with icons.

### 2.1 Instant Actions (no submenu, immediate effect)

| Key | Action | Source |
|-----|--------|--------|
| `<leader>w` | Save (:w) | keymaps.lua |
| `<leader>W` | Save and close (:wq) | keymaps.lua |
| `<leader>e` | File Explorer | snacks.lua |
| `<leader>n` | Notification History | snacks.lua |
| `<leader>N` | Neovim News | snacks.lua |
| `<leader>z` | Zen Mode | snacks.lua |
| `<leader>Z` | Zoom | snacks.lua |
| `<leader>.` | Scratch Buffer | snacks.lua |
| `<leader>S` | Select Scratch Buffer | snacks.lua |
| `<leader><space>` | Smart Find Files | snacks.lua |
| `<leader>,` | Buffers | snacks.lua |
| `<leader>/` | Grep | snacks.lua |
| `<leader>:` | Command History | snacks.lua |
| `<leader>+` / `-` | Increment / Decrement | keymaps.lua |

### 2.2 AI — `<leader>a`

Chat with AI, get code suggestions, and manage inline completions.

**CodeCompanion (Chat & Actions):**

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>aa` | n | Toggle chat | Open/close AI chat sidebar |
| `<leader>aA` | n | New chat | Start fresh conversation |
| `<leader>ap` | n,v | Action palette | Browse all AI actions |
| `<leader>ai` | n,v | Inline edit | Edit code with AI prompt |
| `<leader>ae` | v | Explain | Select code → AI explains it |
| `<leader>af` | v | Fix | Select buggy code → AI fixes it |
| `<leader>at` | v | Tests | Select function → AI writes tests |
| `<leader>ar` | v | Review | Select code → AI reviews it |
| `<leader>ad` | n | Document | Generate docs for function at cursor |
| `<leader>ac` | n | Commit message | AI writes commit message from staged diff |

**Windsurf/Codeium (Inline Completions):**

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>av` | n | Toggle virtual text | Turn ghost text on/off |
| `<leader>aV` | n | Virtual text ON | Force enable ghost text |
| `<leader>ax` | n | Virtual text OFF | Disable for focused editing |
| `<C-l>` | i | Accept suggestion | Accept the ghost text completion |
| `<M-]>` / `<M-[>` | i | Next/prev suggestion | Cycle through alternatives |
| `<M-c>` | i | Clear suggestion | Dismiss current ghost text |

### 2.3 Buffer — `<leader>b`

Manage open buffers (files in memory).

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>bd` | Delete buffer | Close file without closing window |
| `<leader>bo` | Delete other buffers | Clean up — keep only current file |
| `<leader>bp` | Pick buffer by letter | Jump to buffer via overlay letter |

**Quick buffer switching:** `<leader>,` opens the buffer picker. `[b`/`]b` navigates prev/next.

### 2.4 Code — `<leader>c`

LSP-powered code operations. These work in any language with an LSP server.

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>ca` | n,v | Code actions | Fix imports, extract variable, quick fixes |
| `<leader>cr` | n | Rename symbol | Rename variable/function across all files |
| `<leader>cR` | n | Rename file | Rename file + update all imports |
| `<leader>cd` | n | Line diagnostics | Show error/warning popup for current line |
| `<leader>cD` | n | Toggle diagnostics | Hide/show all inline diagnostics |
| `<leader>cf` | n,v | Format file/range | Auto-format code (prettier, gofmt, etc.) |

### 2.5 Debug — `<leader>d`

Debug Adapter Protocol (DAP) — interactive debugger.

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>db` | Toggle breakpoint | Set/remove breakpoint on current line |
| `<leader>dB` | Conditional breakpoint | Break only when expression is true |
| `<leader>dc` | Continue | Start debugging / continue to next breakpoint |
| `<leader>dr` | Open REPL | Interactive debug console |
| `<leader>dl` | Run last | Re-run previous debug session |
| `<leader>dh` | Hover variables | Inspect variable value under cursor |
| `<leader>dp` | Preview | Preview variable in floating window |
| `<leader>df` | Frames | Show call stack frames |
| `<leader>ds` | Scopes | Show variable scopes |
| `<leader>dq` | Quit | Stop debug session and close UI |
| `<leader>du` | Toggle UI | Show/hide debug UI panels |
| `<leader>de` | Eval (n,v) | Evaluate expression or selected code |

**Also:** `<F5>` Continue, `<F10>` Step Over, `<F11>` Step Into, `<F12>` Step Out.

### 2.6 Find — `<leader>f`

Fuzzy file finding (Snacks picker). For text search, see [Search](#212-search--leaders).

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>ff` | Find files | Open any file by name |
| `<leader>fg` | Git files | Find files tracked by git |
| `<leader>fr` | Recent files | Reopen recently edited files |
| `<leader>fs` | Find string (grep) | Search file contents |
| `<leader>fw` | Find word under cursor | Search for the word you're on |
| `<leader>fc` | Find config file | Open Neovim config files |
| `<leader>fb` | Find buffers | Switch between open files |
| `<leader>fp` | Projects | Switch between projects |
| `<leader>ft` | Find todos | Jump to TODO/FIXME comments |

### 2.7 Git — `<leader>g`

Everything Git: status, branches, blame, hunks, and diffview.

**Top-level (2 keystrokes):**

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>gg` | n | Lazygit | Full Git TUI inside Neovim |
| `<leader>gb` | n | Branches | Switch/create/delete branches |
| `<leader>gl` | n | Log | Browse commit history |
| `<leader>gL` | n | Log (current line) | Who last changed this line? |
| `<leader>gs` | n | Status | See changed/staged/untracked files |
| `<leader>gS` | n | Stash | Browse stashed changes |
| `<leader>gd` | n | Diff | See all changed hunks |
| `<leader>gf` | n | Log file | History of current file |
| `<leader>gB` | n,v | Git Browse | Open file on GitHub/GitLab |

**Hunks subgroup — `<leader>gh` (3 keystrokes):**

Stage, reset, and navigate individual changes within a file.

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>ghs` | n,v | Stage hunk | Stage just this change, not the whole file |
| `<leader>ghr` | n,v | Reset hunk | Discard this change |
| `<leader>ghS` | n | Stage buffer | Stage entire file |
| `<leader>ghR` | n | Reset buffer | Discard all changes in file |
| `<leader>ghu` | n | Undo stage | Unstage last staged hunk |
| `<leader>ghp` | n | Preview hunk | See what changed in popup |
| `<leader>ghi` | n | Preview inline | See changes inline |
| `<leader>ghb` | n | Blame line | Who wrote this line? |
| `<leader>ghB` | n | Toggle blame | Show/hide blame for all lines |
| `<leader>ghd` | n | Diff this | Side-by-side diff against index |
| `<leader>ghD` | n | Diff this ~ | Diff against last commit |
| `<leader>ghq` | n | Hunks to quickfix | All hunks in quickfix for navigation |
| `<leader>ghQ` | n | All hunks to quickfix | All hunks across all files |

**Also:** `[h`/`]h` jumps to previous/next hunk. `ih` selects hunk as text object.

**Diffview subgroup — `<leader>gv` (3 keystrokes):**

Full side-by-side diff viewer for reviewing changes.

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>gvv` | Open diffview | Review all uncommitted changes |
| `<leader>gvx` | Close diffview | Return to editing |
| `<leader>gvh` | File history | All commits that changed this file |
| `<leader>gvH` | Branch history | Full commit log of current branch |

### 2.8 LSP/Lint — `<leader>l`

LSP server management and linting configuration.

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>ld` | Toggle diagnostics | Temporarily hide all warnings/errors |
| `<leader>lD` | Diagnostics float | Show diagnostic details in popup |
| `<leader>lc` | Clear diagnostics | Reset diagnostic state |
| `<leader>ll` | Open none-ls log | Debug formatting/linting issues |
| `<leader>li` | Show none-ls info | See active formatters/linters |
| `<leader>ls` | Restart LSP | Fix stuck LSP server |

### 2.9 Markdown — `<leader>m` (ft=markdown)

Only active in Markdown files.

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>mp` | Toggle browser preview | Live preview in browser while editing |
| `<leader>mr` | Toggle render-markdown | In-buffer rendered headings/lists/code |

### 2.10 Quit — `<leader>q`

| Key | Action |
|-----|--------|
| `<leader>qq` | Close buffer |
| `<leader>QQ` | Force close (discard changes) |

### 2.11 Refactor — `<leader>r`

Structural code refactoring (refactoring.nvim by ThePrimeagen).

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>rr` | n,x | Select refactor | Picker showing all refactor options |
| `<leader>re` | x | Extract Function | Select code → extract to new function |
| `<leader>rf` | x | Extract Function To File | Extract to function in separate file |
| `<leader>rv` | x | Extract Variable | Select expression → assign to variable |
| `<leader>ri` | n,x | Inline Variable | Replace variable with its value |
| `<leader>rI` | n | Inline Function | Replace function call with body |
| `<leader>rb` | n | Extract Block | Extract block to new scope |
| `<leader>rbf` | n | Extract Block To File | Extract block to separate file |
| `<leader>rp` | n,x | Debug Print Variable | Insert print statement for variable |
| `<leader>rP` | n | Debug Printf | Insert printf-style debug statement |
| `<leader>rc` | n | Debug Cleanup | Remove all debug print statements |

### 2.12 Search — `<leader>s`

Search everything — files, text, symbols, history, and more (Snacks picker).

| Key | Mode | Action | Example use case |
|-----|------|--------|------------------|
| `<leader>sb` | n | Buffer Lines | Search within current file |
| `<leader>sB` | n | Grep Open Buffers | Search across all open files |
| `<leader>sg` | n | Grep | Full-text search across project |
| `<leader>sw` | n,x | Grep word/selection | Search for word under cursor or selected text |
| `<leader>sr` | n | Search & Replace | Project-wide find and replace (grug-far) |
| `<leader>sR` | n | Search & Replace (file) | Replace in current file only |
| `<leader>s"` | n | Registers | Browse clipboard/register contents |
| `<leader>s/` | n | Search History | Browse previous searches |
| `<leader>sa` | n | Autocmds | Browse autocommands |
| `<leader>sc` | n | Command History | Browse previous commands |
| `<leader>sC` | n | Commands | Browse all available commands |
| `<leader>sd` | n | Diagnostics | Browse all errors/warnings |
| `<leader>sD` | n | Buffer Diagnostics | Diagnostics in current file only |
| `<leader>sh` | n | Help Pages | Search Neovim help |
| `<leader>sH` | n | Highlights | Browse highlight groups |
| `<leader>si` | n | Icons | Search Nerd Font icons |
| `<leader>sj` | n | Jumps | Browse jump list |
| `<leader>sk` | n | Keymaps | Search all keybindings |
| `<leader>sl` | n | Location List | Browse location list |
| `<leader>sm` | n | Marks | Browse marks |
| `<leader>sM` | n | Man Pages | Search man pages |
| `<leader>sp` | n | Plugin Spec | Browse lazy.nvim plugin specs |
| `<leader>sq` | n | Quickfix List | Browse quickfix list |
| `<leader>sP` | n | Resume | Resume last picker |
| `<leader>ss` | n | LSP Symbols | Browse symbols in current file |
| `<leader>sS` | n | LSP Workspace Symbols | Browse symbols across project |
| `<leader>st` | n | Todo Comments | Browse TODO/FIXME/HACK comments |
| `<leader>sT` | n | Todo/Fix/Fixme | Filtered todo comments |
| `<leader>su` | n | Undo History | Browse and restore undo states |

### 2.13 Tests — `<leader>t`

Run and navigate tests (neotest).

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>tt` | Run nearest test | Run the test your cursor is in |
| `<leader>tf` | Run file tests | Run all tests in current file |
| `<leader>ta` | Run all tests | Run entire test suite |
| `<leader>ts` | Toggle summary | Show/hide test result sidebar |
| `<leader>to` | Show output | See output of last test run |
| `<leader>tp` | Output panel | Toggle persistent output panel |
| `<leader>td` | Debug test | Run nearest test with debugger attached |
| `<leader>tS` | Stop | Cancel running test |
| `<leader>tl` | Re-run last | Repeat the last test run |

**Also:** `[T`/`]T` jumps to previous/next failed test.

### 2.14 Tabs — `<leader><Tab>`

Tab management (Vim tabs, not buffers).

| Key | Action |
|-----|--------|
| `<leader><Tab><Tab>` | Open new tab |
| `<leader><Tab>x` or `d` | Close tab |
| `<leader><Tab>]` or `n` | Next tab |
| `<leader><Tab>[` or `p` | Previous tab |
| `<leader><Tab>f` | Move buffer to new tab |

### 2.15 UI Toggles — `<leader>u`

Toggle visual and editor features on/off.

| Key | Action |
|-----|--------|
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle word wrap |
| `<leader>uL` | Toggle relative numbers |
| `<leader>ul` | Toggle line numbers |
| `<leader>ud` | Toggle dim inactive |
| `<leader>uc` | Toggle conceal |
| `<leader>uT` | Toggle treesitter highlight |
| `<leader>ub` | Toggle dark/light background |
| `<leader>uh` | Toggle inlay hints |
| `<leader>ug` | Toggle indent guides |
| `<leader>uD` | Toggle diagnostics |
| `<leader>un` | Dismiss notifications |
| `<leader>uC` | Colorschemes (picker) |
| `<leader>ux` | Toggle treesitter context |
| `<leader>uH` | Toggle colorizer (color previews) |
| `<leader>ua` | Toggle animations |

### 2.16 Save + Session — `<leader>w`

`<leader>w` alone saves immediately. Session commands use subkeys.

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>w` | Save (:w) | **Instant, no delay** |
| `<leader>wr` | Restore session | Reopen all files from last session |
| `<leader>ws` | Save session | Save current workspace layout |
| `<leader>wd` | Delete session | Remove saved session for this directory |
| `<leader>wf` | Find sessions | Browse and pick from saved sessions |

> **Note:** Session subkeys cause a slight delay on `<leader>w` (which-key timeout).
> If this is annoying, use `<C-s>` for saving instead — it's instant from any mode.

### 2.17 Trouble — `<leader>x`

Diagnostic and reference panels (Trouble.nvim).

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>xw` | Workspace diagnostics | All errors/warnings across project |
| `<leader>xd` | Document diagnostics | Errors/warnings in current file |
| `<leader>xq` | Quickfix list | Browse quickfix entries |
| `<leader>xl` | Location list | Browse location list entries |
| `<leader>xt` | Todos | All TODO/FIXME comments in project |
| `<leader>xs` | Symbols outline | Code structure sidebar (functions, classes) |
| `<leader>xL` | LSP references panel | All references to symbol under cursor |

### 2.18 YAML & K8s — `<leader>y` (ft=yaml)

Only active in YAML files. Three tools integrated under one prefix.

**yaml.nvim — Navigation & Yank:**

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>yv` | Show path + value | See full YAML path at cursor |
| `<leader>yy` | Yank path + value | Copy `spec.containers[0].image: nginx` |
| `<leader>yk` | Yank key | Copy just `spec.containers[0].image` |
| `<leader>yV` | Yank value | Copy just `nginx` |
| `<leader>yq` | Quickfix (paths) | All YAML paths in quickfix list |
| `<leader>yh` | Remove highlight | Clear YAML path highlight |
| `<leader>yp` | Path picker | Fuzzy search YAML paths |

**yaml-companion — Schema:**

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>ys` | Select schema | Switch YAML schema (K8s Deployment, docker-compose...) |
| `<leader>yS` | Show current schema | See which schema is active |
| `<leader>yd` | Browse Datree CRDs | Browse community CRD schemas |
| `<leader>yc` | Browse cluster CRDs | Import CRDs from connected cluster |
| `<leader>ym` | Add CRD modelines | Add schema modeline comment to file |
| `<leader>yQ` | Keys to quickfix | All YAML keys in quickfix list |

**kubernetes.nvim:**

| Key | Action | Example use case |
|-----|--------|------------------|
| `<leader>yK` | Regenerate K8s schema | Refresh schema from connected K8s cluster |

### 2.19 Zen/Zoom

| Key | Action |
|-----|--------|
| `<leader>z` | Zen Mode (distraction-free writing) |
| `<leader>Z` | Zoom (toggle current window fullscreen) |

---

## 3. Language-Specific Groups

These groups only appear in which-key when you're editing the relevant filetype.

### 3.1 Go — `<leader>G` (ft=go)

| Key | Action |
|-----|--------|
| **Tags** (`<leader>Gt`) | |
| `<leader>Gtj` | Add json tags to struct |
| `<leader>Gty` | Add yaml tags to struct |
| `<leader>Gtx` | Add xml tags to struct |
| `<leader>Gtr` | Remove tags from struct |
| **Module** (`<leader>Gm`) | |
| `<leader>Gmt` | go mod tidy |
| `<leader>Gmi` | go mod init |
| `<leader>Gmg` | go mod get |
| **Generate** (`<leader>Gi`) | |
| `<leader>Gii` | Implement interface |
| `<leader>Gie` | Generate if err |
| **Other** | |
| `<leader>Gc` | Generate doc comment |
| `<leader>Gg` | go generate |
| `<leader>GG` | go generate (current file) |
| `<leader>Gta/GtA/Gte` | Generate tests: func / all / exported |

### 3.2 Rust — `<leader>R` (ft=rust)

| Key | Action |
|-----|--------|
| `<leader>Re` | Expand macro recursively |
| `<leader>Rc` | Open Cargo.toml |
| `<leader>Rp` | Go to parent module |
| `<leader>Rd` | Render diagnostic (full error) |
| `<leader>Rr` | Runnables (pick and run) |
| `<leader>RD` | Debuggables (pick and debug) |
| `<leader>Rj` | Join lines (Rust-aware) |
| `<leader>Ra` | Rust-specific code action |
| **Crates** (`<leader>Rc`, ft=toml) | |
| `<leader>Rcu` | Upgrade all crates |
| `<leader>Rci` | Show crate info popup |
| `<leader>Rcv` | Show crate versions |
| `<leader>Rcf` | Show crate features |
| `<leader>Rcd` | Show crate dependencies |

---

## 4. Non-Leader Keymaps

Keys that work without pressing `<leader>` first.

### 4.1 LSP Navigation

| Key | Action | Mnemonic |
|-----|--------|----------|
| `gd` | Go to definition | **g**o **d**efinition |
| `gD` | Go to declaration | **g**o **D**eclaration |
| `gr` | Find references | **g**o **r**eferences |
| `gI` | Go to implementation | **g**o **I**mplementation |
| `gy` | Go to type definition | **g**o t**y**pe |
| `K` | Hover documentation | |

### 4.2 Bracket Navigation — `[x` / `]x`

All bracket pairs follow the same pattern: `[` = previous, `]` = next.

| Key | Action | Source |
|-----|--------|--------|
| `[d` / `]d` | Previous/next diagnostic | lspconfig |
| `[h` / `]h` | Previous/next git hunk | gitsigns |
| `[t` / `]t` | Previous/next TODO comment | todo-comments |
| `[T` / `]T` | Previous/next failed test | neotest |
| `[b` / `]b` | Previous/next buffer | keymaps |
| `[q` / `]q` | Previous/next quickfix | keymaps |
| `[e` / `]e` | Previous/next error | keymaps |
| `[w` / `]w` | Previous/next warning | keymaps |
| `[x` | Jump to treesitter context | treesitter-context |
| `[m` / `]m` | Previous/next function start | treesitter |
| `[M` / `]M` | Previous/next function end | treesitter |
| `[c` / `]c` | Previous/next class start | treesitter |
| `[C` / `]C` | Previous/next class end | treesitter |
| `[i` / `]i` | Previous/next conditional start | treesitter |
| `[I` / `]I` | Previous/next conditional end | treesitter |
| `[l` / `]l` | Previous/next loop start | treesitter |
| `[L` / `]L` | Previous/next loop end | treesitter |
| `[a` / `]a` | Swap parameter with prev/next | treesitter |
| `]]` / `[[` | Next/prev word reference | snacks |

### 4.3 Flash Navigation

| Key | Mode | Action |
|-----|------|--------|
| `s` | n,x,o | Flash jump — type 2 chars to jump anywhere visible |
| `S` | n,x,o | Flash treesitter — select by syntax node |
| `f`/`F`/`t`/`T` | n,x,o | Enhanced motions with labels |
| `r` | o | Remote flash (operate on distant text) |
| `R` | o,x | Treesitter search |
| `<C-s>` | c | Toggle flash in search |

### 4.4 Folds (ufo.nvim)

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open one fold level (incremental) |
| `zm` | Close one fold level (incremental) |
| `zK` | Peek fold preview |

### 4.5 Window Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` | n,t | Go to left window |
| `<C-j>` | n,t | Go to lower window |
| `<C-k>` | n,t | Go to upper window |
| `<C-l>` | n,t | Go to right window |

### 4.6 Window Resize

| Key | Action |
|-----|--------|
| `<C-Up>` | Increase window height |
| `<C-Down>` | Decrease window height |
| `<C-Left>` | Decrease window width |
| `<C-Right>` | Increase window width |

### 4.7 Line Movement

| Key | Mode | Action |
|-----|------|--------|
| `<A-j>` | n,i,v | Move line(s) down |
| `<A-k>` | n,i,v | Move line(s) up |

### 4.8 Yank (yanky.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `y` | n,x | Yank (enhanced — saved to history) |
| `p` / `P` | n,x | Paste after / before |
| `<C-p>` | n | Previous entry in yank history |
| `<C-n>` | n | Next entry in yank history |

### 4.9 Comments (Comment.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | n | Toggle line comment |
| `gbc` | n | Toggle block comment |
| `gc` | n,v | Comment operator (motion / selection) |
| `gb` | v | Block comment selection |
| `gco` | n | Add comment below |
| `gcO` | n | Add comment above |
| `gcA` | n | Add comment at end of line |

### 4.10 Scroll (Snacks — automatic smooth scrolling)

These are native Vim keys — Snacks.scroll makes them animated.

| Key | Action |
|-----|--------|
| `<C-u>` / `<C-d>` | Smooth half-page up / down |
| `<C-b>` / `<C-f>` | Smooth full page up / down |
| `<C-y>` / `<C-e>` | Smooth one line up / down |
| `zt` / `zz` / `zb` | Scroll cursor to top / center / bottom |

### 4.11 Misc

| Key | Mode | Action |
|-----|------|--------|
| `<C-s>` | i,n,v,s | Save file |
| `<C-/>` | n,t | Toggle terminal |
| `j` / `k` | n,x | Smart movement (visual lines when wrapped) |
| `<Esc>` | n | Clear search highlights |
| `<` / `>` | v | Indent/unindent (keeps selection) |
| `<F5>` | n | Debug: Start/Continue |
| `<F10>` | n | Debug: Step Over |
| `<F11>` | n | Debug: Step Into |
| `<F12>` | n | Debug: Step Out |

---

## 5. Text Objects (Treesitter)

Use with operators: `d` (delete), `c` (change), `y` (yank), `v` (select).
Example: `daf` = delete around function, `cii` = change inside if-block.

### 5.1 Selection Objects

| Key | Selects | Selection mode | Example |
|-----|---------|---------------|---------|
| `af` / `if` | Function (around / inside) | linewise | `daf` deletes entire function |
| `ac` / `ic` | Class (around / inside) | linewise | `vic` selects class body |
| `aa` / `ia` | Parameter (around / inside) | charwise | `cia` changes argument |
| `ai` / `ii` | Conditional (around / inside) | linewise | `dai` deletes if-block |
| `al` / `il` | Loop (around / inside) | linewise | `vil` selects loop body |
| `ab` / `ib` | Block (around / inside) | linewise | `dab` deletes code block |
| `aC` / `iC` | Function call (around / inside) | charwise | `daC` deletes entire call |
| `as` / `is` | Assignment (key: value / value) | line/char | `dis` deletes value only |
| `ak` | Assignment key (left side) | charwise | `yak` yanks the key |
| `av` | Assignment value (right side) | charwise | `cav` changes the value |
| `an` | Number | charwise | `dan` deletes a number |
| `at` / `it` | Comment (around / inside) | line/char | `dat` deletes comment |
| `aS` | Statement (outer) | linewise | `daS` deletes YAML statement |
| `ih` | Git hunk | charwise | `dih` deletes unstaged change |

### 5.2 Incremental Selection

| Key | Mode | Action |
|-----|------|--------|
| `<C-Enter>` | n | Start selection (selects word under cursor) |
| `<C-Enter>` | v | Expand to next larger syntax node |
| `<C-Backspace>` | v | Shrink to next smaller syntax node |

**Example flow:** cursor on `"hello"` → `<C-Enter>` selects `"hello"` → again selects `print("hello")` → again selects the full statement → again selects the function body → etc.

---

## 6. Insert Mode Keys

| Key | Action | Source |
|-----|--------|--------|
| `jj` / `jk` | Exit insert mode | keymaps.lua |
| `<C-s>` | Save file | keymaps.lua |
| `<C-l>` | Accept Windsurf completion | windsurf.lua |
| `<M-]>` / `<M-[>` | Next/prev Windsurf suggestion | windsurf.lua |
| `<M-c>` | Clear Windsurf suggestion | windsurf.lua |
| `<A-j>` / `<A-k>` | Move line down/up | keymaps.lua |
| `,` / `.` / `;` | Self + undo breakpoint | keymaps.lua |
| `<Tab>` | Smart: next completion → jump snippet → trigger | nvim-cmp |
| `<S-Tab>` | Smart: prev completion → jump back | nvim-cmp |
| `<C-b>` / `<C-f>` | Scroll completion docs up/down | nvim-cmp |
| `<C-e>` | Close completion menu | nvim-cmp |
