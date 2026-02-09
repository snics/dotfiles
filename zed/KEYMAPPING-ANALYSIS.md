# NeoVim to Zed Keymapping Analysis

Comprehensive mapping of every NeoVim keybinding from `nvim/KEYMAPPING.md` to Zed equivalents.

**Zed vim mode context:** `vim_mode` is enabled in `settings.json`. Zed supports which-key via `which_key.enabled: true`.
**Leader key:** In Zed vim mode, `space` is the leader key (same as NeoVim config).

---

## Section A: Mappable in Zed

### A.1 Instant Actions (no submenu)

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>w` | Save (:w) | `vim::WriteFile` (or `:w`) | Built-in via vim `:w`. Custom: `{"context":"vim_mode == normal","bindings":{"space w":"workspace::Save"}}` |
| `<leader>W` | Save and close (:wq) | `vim::WriteQuit` (or `:wq`) | `{"context":"vim_mode == normal","bindings":{"space shift-w":["workspace::SendKeystrokes",": w q enter"]}}` |
| `<leader>e` | File Explorer | `project_panel::ToggleFocus` | `{"context":"vim_mode == normal","bindings":{"space e":"project_panel::ToggleFocus"}}` |
| `<leader><space>` | Smart Find Files | `file_finder::Toggle` | `{"context":"vim_mode == normal","bindings":{"space space":"file_finder::Toggle"}}` |
| `<leader>,` | Switch buffer | `tab_switcher::Toggle` | `{"context":"vim_mode == normal","bindings":{"space ,":"tab_switcher::Toggle"}}` |
| `<leader>/` | Grep across project | `pane::DeploySearch` | `{"context":"vim_mode == normal","bindings":{"space /":"pane::DeploySearch"}}` |
| `<leader>:` | Command History | `command_palette::Toggle` | `{"context":"vim_mode == normal","bindings":{"space :":"command_palette::Toggle"}}` |
| `<leader>z` | Zen Mode | `workspace::ToggleCenteredLayout` | `{"context":"vim_mode == normal","bindings":{"space z":"workspace::ToggleCenteredLayout"}}` |
| `<leader>Z` | Zoom (fullscreen pane) | `workspace::ToggleZoom` | `{"context":"vim_mode == normal","bindings":{"space shift-z":"workspace::ToggleZoom"}}` |
| `<leader>+` | Increment number | `vim::Increment` | Built-in via `ctrl-a` in vim. Custom: `{"context":"vim_mode == normal","bindings":{"space +":"vim::Increment"}}` |
| `<leader>-` | Decrement number | `vim::Decrement` | Built-in via `ctrl-x` in vim. Custom: `{"context":"vim_mode == normal","bindings":{"space -":"vim::Decrement"}}` |

### A.2 AI -- `<leader>a`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>aa` | Toggle AI chat | `assistant::ToggleFocus` | `{"context":"vim_mode == normal","bindings":{"space a a":"assistant::ToggleFocus"}}` |
| `<leader>aA` | New chat | `assistant::NewThread` | `{"context":"vim_mode == normal","bindings":{"space a shift-a":"assistant::NewThread"}}` |
| `<leader>ai` | Inline edit (n,v) | `assistant::InlineAssist` | `{"context":"VimControl","bindings":{"space a i":"assistant::InlineAssist"}}` |
| `<leader>ap` | Action palette | `command_palette::Toggle` | `{"context":"VimControl","bindings":{"space a p":"command_palette::Toggle"}}` |
| `<leader>ad` | Document code | `assistant::InlineAssist` | Use inline assist with a "document this" prompt. `{"context":"vim_mode == normal","bindings":{"space a d":"assistant::InlineAssist"}}` |
| `<leader>ac` | Commit message | N/A (no direct action) | Could use a task: `{"context":"vim_mode == normal","bindings":{"space a c":"assistant::InlineAssist"}}` |
| `<leader>av` | Toggle virtual text (completions) | `editor::ToggleInlineCompletions` | `{"context":"vim_mode == normal","bindings":{"space a v":"editor::ToggleInlineCompletions"}}` |

### A.3 Buffer -- `<leader>b`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>bd` | Delete buffer | `pane::CloseActiveItem` | `{"context":"vim_mode == normal","bindings":{"space b d":"pane::CloseActiveItem"}}` |
| `<leader>bo` | Delete other buffers | `pane::CloseInactiveItems` | `{"context":"vim_mode == normal","bindings":{"space b o":"pane::CloseInactiveItems"}}` |

### A.4 Code -- `<leader>c`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>ca` | Code actions (n,v) | `editor::ToggleCodeActions` | `{"context":"VimControl","bindings":{"space c a":"editor::ToggleCodeActions"}}` |
| `<leader>cr` | Rename symbol | `editor::Rename` | `{"context":"vim_mode == normal","bindings":{"space c r":"editor::Rename"}}` |
| `<leader>cR` | Rename file | `project_panel::Rename` | `{"context":"vim_mode == normal","bindings":{"space c shift-r":"project_panel::Rename"}}` |
| `<leader>cd` | Line diagnostics | `editor::Hover` | `{"context":"vim_mode == normal","bindings":{"space c d":"editor::Hover"}}` |
| `<leader>cf` | Format file/range (n,v) | `editor::Format` | `{"context":"VimControl","bindings":{"space c f":"editor::Format"}}` |

### A.5 Find -- `<leader>f`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>ff` | Find files | `file_finder::Toggle` | `{"context":"vim_mode == normal","bindings":{"space f f":"file_finder::Toggle"}}` |
| `<leader>fr` | Recent files | `recent_projects::OpenRecent` (or `file_finder::Toggle` with recency sort) | `{"context":"vim_mode == normal","bindings":{"space f r":"projects::OpenRecent"}}` |
| `<leader>fs` | Find string (grep) | `pane::DeploySearch` | `{"context":"vim_mode == normal","bindings":{"space f s":"pane::DeploySearch"}}` |
| `<leader>fw` | Find word under cursor | `editor::SelectNext` then search, or `pane::DeploySearch` | `{"context":"vim_mode == normal","bindings":{"space f w":["workspace::SendKeystrokes","g /"]}}` (uses vim `g /` project search) |
| `<leader>fb` | Find buffers | `tab_switcher::Toggle` | `{"context":"vim_mode == normal","bindings":{"space f b":"tab_switcher::Toggle"}}` |
| `<leader>ft` | Find todos | `todo_tree::Toggle` (via extension) | Requires a TODO extension. `{"context":"vim_mode == normal","bindings":{"space f t":["pane::DeploySearch",{"query":"TODO\\|FIXME\\|HACK"}]}}` |

### A.6 Git -- `<leader>g`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>gb` | Branches | `branches::OpenRecent` | `{"context":"vim_mode == normal","bindings":{"space g b":"branches::OpenRecent"}}` |
| `<leader>gs` | Git status | `git_panel::ToggleFocus` | `{"context":"vim_mode == normal","bindings":{"space g s":"git_panel::ToggleFocus"}}` |
| `<leader>gd` | Diff | `editor::ToggleHunkDiff` | `{"context":"vim_mode == normal","bindings":{"space g d":"editor::ToggleHunkDiff"}}` |
| `<leader>gB` | Git Browse (open on GitHub) | `editor::OpenPermalink` | `{"context":"VimControl","bindings":{"space g shift-b":"editor::OpenPermalink"}}` |
| `<leader>ghb` | Blame line | `editor::ToggleGitBlame` | `{"context":"vim_mode == normal","bindings":{"space g h b":"editor::ToggleGitBlame"}}` |
| `<leader>ghB` | Toggle blame (all lines) | `editor::ToggleGitBlame` | `{"context":"vim_mode == normal","bindings":{"space g h shift-b":"editor::ToggleGitBlame"}}` |
| `<leader>ghs` | Stage hunk | `editor::StageAndNext` (vim `d u`) | `{"context":"VimControl","bindings":{"space g h s":["workspace::SendKeystrokes","d u"]}}` |
| `<leader>ghr` | Reset hunk | `editor::RevertHunk` (vim `d p`) | `{"context":"VimControl","bindings":{"space g h r":["workspace::SendKeystrokes","d p"]}}` |
| `<leader>ghp` | Preview hunk | `editor::ToggleHunkDiff` (vim `d o`) | `{"context":"vim_mode == normal","bindings":{"space g h p":["workspace::SendKeystrokes","d o"]}}` |
| `]h` / `[h` | Next/prev git hunk | `]c` / `[c` in Zed vim | Built-in: `]c` and `[c` in Zed vim mode |

### A.7 LSP/Lint -- `<leader>l`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>ld` | Toggle diagnostics | `diagnostics::Toggle` | `{"context":"vim_mode == normal","bindings":{"space l d":"diagnostics::Deploy"}}` |
| `<leader>lD` | Diagnostics float | `editor::Hover` | `{"context":"vim_mode == normal","bindings":{"space l shift-d":"editor::Hover"}}` |
| `<leader>ls` | Restart LSP | `lsp::RestartLanguageServer` | `{"context":"vim_mode == normal","bindings":{"space l s":"lsp::RestartLanguageServer"}}` |

### A.8 Quit -- `<leader>q`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>qq` | Close buffer | `pane::CloseActiveItem` | `{"context":"vim_mode == normal","bindings":{"space q q":"pane::CloseActiveItem"}}` |
| `<leader>qQ` | Force close (discard) | `pane::CloseActiveItem` (with `{"save_intent":"skip"}`) | `{"context":"vim_mode == normal","bindings":{"space q shift-q":["pane::CloseActiveItem",{"save_intent":"skip"}]}}` |

### A.9 Search -- `<leader>s`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>sb` | Buffer lines | `editor::ToggleFind` | `{"context":"vim_mode == normal","bindings":{"space s b":"buffer_search::Deploy"}}` |
| `<leader>sB` | Grep open buffers | `pane::DeploySearch` | `{"context":"vim_mode == normal","bindings":{"space s shift-b":"pane::DeploySearch"}}` |
| `<leader>sg` | Grep project | `pane::DeploySearch` | `{"context":"vim_mode == normal","bindings":{"space s g":"pane::DeploySearch"}}` |
| `<leader>sw` | Grep word/selection (n,x) | `editor::SearchDeploy` with current word | `{"context":"VimControl","bindings":{"space s w":"editor::SelectNext"}}` or use `g /` |
| `<leader>sr` | Search & Replace | `pane::DeploySearch` with replace | `{"context":"vim_mode == normal","bindings":{"space s r":["pane::DeploySearch",{"replace_enabled":true}]}}` |
| `<leader>sd` | Diagnostics | `diagnostics::Deploy` | `{"context":"vim_mode == normal","bindings":{"space s d":"diagnostics::Deploy"}}` |
| `<leader>sD` | Buffer diagnostics | `diagnostics::Deploy` | `{"context":"vim_mode == normal","bindings":{"space s shift-d":"diagnostics::Deploy"}}` |
| `<leader>sc` | Command history | `command_palette::Toggle` | `{"context":"vim_mode == normal","bindings":{"space s c":"command_palette::Toggle"}}` |
| `<leader>sC` | Commands | `command_palette::Toggle` | `{"context":"vim_mode == normal","bindings":{"space s shift-c":"command_palette::Toggle"}}` |
| `<leader>ss` | LSP Symbols (file) | `outline::Toggle` | `{"context":"vim_mode == normal","bindings":{"space s s":"outline::Toggle"}}` |
| `<leader>sS` | LSP Workspace Symbols | `project_symbols::Toggle` | `{"context":"vim_mode == normal","bindings":{"space s shift-s":"project_symbols::Toggle"}}` |
| `<leader>sP` | Resume last picker | N/A (Zed has no "resume picker") | Not directly available |
| `<leader>st` | Todo comments | Search for TODO pattern | `{"context":"vim_mode == normal","bindings":{"space s t":["pane::DeploySearch",{"query":"TODO\\|FIXME\\|HACK"}]}}` |

### A.10 Test -- `<leader>t`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>tt` | Run nearest test | `editor::RunNearestTest` (gutter runnable) | `{"context":"vim_mode == normal","bindings":{"space t t":"task::Rerun"}}` (or use gutter play button) |
| `<leader>ta` | Run all tests | `task::Spawn` | `{"context":"vim_mode == normal","bindings":{"space t a":"task::Spawn"}}` |
| `<leader>tl` | Re-run last test | `task::Rerun` | `{"context":"vim_mode == normal","bindings":{"space t l":"task::Rerun"}}` |

### A.11 Tabs -- `<leader><Tab>`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader><Tab><Tab>` | New tab | `:tabnew` in vim or `workspace::NewFile` | `{"context":"vim_mode == normal","bindings":{"space tab tab":"workspace::NewFile"}}` |
| `<leader><Tab>x` | Close tab | `pane::CloseActiveItem` | `{"context":"vim_mode == normal","bindings":{"space tab x":"pane::CloseActiveItem"}}` |
| `<leader><Tab>]` | Next tab | `pane::ActivateNextItem` | `{"context":"vim_mode == normal","bindings":{"space tab ]":"pane::ActivateNextItem"}}` |
| `<leader><Tab>[` | Previous tab | `pane::ActivatePrevItem` | `{"context":"vim_mode == normal","bindings":{"space tab [":"pane::ActivatePrevItem"}}` |

### A.12 UI Toggles -- `<leader>u`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>uw` | Toggle word wrap | `editor::ToggleSoftWrap` | `{"context":"vim_mode == normal","bindings":{"space u w":"editor::ToggleSoftWrap"}}` |
| `<leader>ul` | Toggle line numbers | `editor::ToggleLineNumbers` | `{"context":"vim_mode == normal","bindings":{"space u l":"editor::ToggleLineNumbers"}}` |
| `<leader>uL` | Toggle relative numbers | `editor::ToggleRelativeLineNumbers` | `{"context":"vim_mode == normal","bindings":{"space u shift-l":"editor::ToggleRelativeLineNumbers"}}` |
| `<leader>uh` | Toggle inlay hints | `editor::ToggleInlayHints` | `{"context":"vim_mode == normal","bindings":{"space u h":"editor::ToggleInlayHints"}}` |
| `<leader>ug` | Toggle indent guides | `editor::ToggleIndentGuides` | `{"context":"vim_mode == normal","bindings":{"space u g":"editor::ToggleIndentGuides"}}` |
| `<leader>uD` | Toggle diagnostics | `diagnostics::Toggle` | `{"context":"vim_mode == normal","bindings":{"space u shift-d":"diagnostics::Deploy"}}` |
| `<leader>un` | Dismiss notifications | `notification::DismissAll` | `{"context":"vim_mode == normal","bindings":{"space u n":"notification::DismissAll"}}` |
| `<leader>uC` | Colorschemes picker | `theme_selector::Toggle` | `{"context":"vim_mode == normal","bindings":{"space u shift-c":"theme_selector::Toggle"}}` |
| `<leader>ub` | Toggle dark/light background | `theme_selector::Toggle` | `{"context":"vim_mode == normal","bindings":{"space u b":"theme_selector::Toggle"}}` |

### A.13 Save + Session -- `<leader>w`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>w` | Save (:w) | `workspace::Save` | `{"context":"vim_mode == normal","bindings":{"space w":"workspace::Save"}}` |

### A.14 Trouble (Diagnostics panels) -- `<leader>x`

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<leader>xw` | Workspace diagnostics | `diagnostics::Deploy` | `{"context":"vim_mode == normal","bindings":{"space x w":"diagnostics::Deploy"}}` |
| `<leader>xd` | Document diagnostics | `diagnostics::Deploy` | `{"context":"vim_mode == normal","bindings":{"space x d":"diagnostics::Deploy"}}` |
| `<leader>xs` | Symbols outline | `outline::Toggle` | `{"context":"vim_mode == normal","bindings":{"space x s":"outline::Toggle"}}` |
| `<leader>xL` | LSP references panel | `editor::FindAllReferences` | `{"context":"vim_mode == normal","bindings":{"space x shift-l":"editor::FindAllReferences"}}` |

### A.15 Non-Leader: LSP Navigation

| NeoVim Key | NeoVim Action | Zed Vim Built-in | Notes |
|---|---|---|---|
| `gd` | Go to definition | `g d` | Built-in in Zed vim mode |
| `gD` | Go to declaration | `g D` | Built-in in Zed vim mode |
| `gr` | Find references | `g A` | Zed uses `g A` not `g r`. Remap: `{"context":"vim_mode == normal","bindings":{"g r":"editor::FindAllReferences"}}` |
| `gI` | Go to implementation | `g I` | Built-in in Zed vim mode |
| `gy` | Go to type definition | `g y` | Built-in in Zed vim mode |
| `K` | Hover documentation | `g h` or `K` | `g h` is Zed default. `K` may need mapping: `{"context":"vim_mode == normal","bindings":{"shift-k":"editor::Hover"}}` |

### A.16 Non-Leader: Bracket Navigation `[x` / `]x`

| NeoVim Key | NeoVim Action | Zed Vim Built-in | Notes |
|---|---|---|---|
| `[d` / `]d` | Prev/next diagnostic | `[ d` / `] d` (or `g [` / `g ]`) | Built-in |
| `[h` / `]h` | Prev/next git hunk | `[ c` / `] c` | Different key! Remap if wanted: `{"context":"VimControl","bindings":{"[ h":["workspace::SendKeystrokes","[ c"],"] h":["workspace::SendKeystrokes","] c"]}}` |
| `[b` / `]b` | Prev/next buffer | `pane::ActivatePrevItem` / `pane::ActivateNextItem` | `{"context":"VimControl","bindings":{"[ b":"pane::ActivatePrevItem","] b":"pane::ActivateNextItem"}}` |
| `[m` / `]m` | Prev/next function start | `[ m` / `] m` | Built-in |
| `[M` / `]M` | Prev/next function end | `[ M` / `] M` | Built-in |
| `]]` / `[[` | Next/prev section | `] ]` / `[ [` | Built-in |

### A.17 Non-Leader: Comments

| NeoVim Key | NeoVim Action | Zed Vim Built-in | Notes |
|---|---|---|---|
| `gcc` | Toggle line comment | `gcc` | Built-in in Zed vim mode |
| `gc` (visual) | Comment selection | `gc` | Built-in in Zed vim mode |
| `gbc` | Toggle block comment | Not built-in | Need custom mapping |
| `gco` | Add comment below | Not built-in | Zed vim lacks this |
| `gcO` | Add comment above | Not built-in | Zed vim lacks this |
| `gcA` | Add comment at end of line | Not built-in | Zed vim lacks this |

### A.18 Non-Leader: Folds

| NeoVim Key | NeoVim Action | Zed Action | Notes |
|---|---|---|---|
| `zR` | Open all folds | `editor::UnfoldAll` | `{"context":"VimControl","bindings":{"z shift-r":"editor::UnfoldAll"}}` (may be built-in) |
| `zM` | Close all folds | `editor::FoldAll` | `{"context":"VimControl","bindings":{"z shift-m":"editor::FoldAll"}}` (may be built-in) |
| `zr` | Open one fold level | `editor::UnfoldAtLevel` | Partial support |
| `zm` | Close one fold level | `editor::FoldAtLevel` | Partial support |

### A.19 Non-Leader: Window Navigation

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<C-h>` | Go to left window | `workspace::ActivatePaneLeft` | `{"context":"vim_mode == normal","bindings":{"ctrl-h":"workspace::ActivatePaneLeft"}}` |
| `<C-j>` | Go to lower window | `workspace::ActivatePaneDown` | `{"context":"vim_mode == normal","bindings":{"ctrl-j":"workspace::ActivatePaneDown"}}` |
| `<C-k>` | Go to upper window | `workspace::ActivatePaneUp` | `{"context":"vim_mode == normal","bindings":{"ctrl-k":"workspace::ActivatePaneUp"}}` |
| `<C-l>` | Go to right window | `workspace::ActivatePaneRight` | `{"context":"vim_mode == normal","bindings":{"ctrl-l":"workspace::ActivatePaneRight"}}` |

### A.20 Non-Leader: Window Resize

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<C-Up>` | Increase height | `workspace::IncreaseActiveItemSize` | Zed doesn't have directional resize. Approximate with: `{"bindings":{"ctrl-up":"workspace::IncreaseActiveItemSize"}}` |
| `<C-Down>` | Decrease height | `workspace::DecreaseActiveItemSize` | `{"bindings":{"ctrl-down":"workspace::DecreaseActiveItemSize"}}` |

### A.21 Non-Leader: Line Movement

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<A-j>` (n) | Move line down | `editor::MoveLineDown` | `{"context":"vim_mode == normal","bindings":{"alt-j":"editor::MoveLineDown"}}` |
| `<A-k>` (n) | Move line up | `editor::MoveLineUp` | `{"context":"vim_mode == normal","bindings":{"alt-k":"editor::MoveLineUp"}}` |
| `<A-j>` (v) | Move selection down | `editor::MoveLineDown` | `{"context":"vim_mode == visual","bindings":{"alt-j":"editor::MoveLineDown"}}` |
| `<A-k>` (v) | Move selection up | `editor::MoveLineUp` | `{"context":"vim_mode == visual","bindings":{"alt-k":"editor::MoveLineUp"}}` |

### A.22 Non-Leader: Surround (vim-surround)

| NeoVim Key | NeoVim Action | Zed Vim Built-in | Notes |
|---|---|---|---|
| `ys` + motion | Add surround | `ys` | Built-in |
| `cs` + old + new | Change surround | `cs` | Built-in |
| `ds` + target | Delete surround | `ds` | Built-in |

### A.23 Non-Leader: Misc

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<C-s>` | Save file (any mode) | `workspace::Save` | `{"bindings":{"ctrl-s":"workspace::Save"}}` |
| `<C-/>` | Toggle terminal | `terminal_panel::ToggleFocus` | `{"context":"Workspace","bindings":{"ctrl-/":"terminal_panel::ToggleFocus"}}` |
| `<Esc>` (normal) | Clear search highlights | `editor::ClearHighlights` | Typically built-in with vim `:noh`. Can map: `{"context":"vim_mode == normal","bindings":{"escape":["workspace::SendKeystrokes",": n o h enter"]}}` |
| `<`/`>` (visual) | Indent/unindent | `editor::Indent`/`editor::Outdent` | Built-in in Zed vim visual mode (`<` and `>`) |
| `j`/`k` | Smart movement (display lines) | Built-in | Vim `gj`/`gk` behavior. Zed handles wrapped lines. |
| `jj`/`jk` (insert) | Exit insert mode | Use `workspace::SendKeystrokes` | `{"context":"vim_mode == insert","bindings":{"j j":"vim::NormalBefore","j k":"vim::NormalBefore"}}` |

### A.24 Non-Leader: Scroll

| NeoVim Key | NeoVim Action | Zed Action | Notes |
|---|---|---|---|
| `<C-u>` / `<C-d>` | Half-page up/down | Built-in | Standard vim motions, work in Zed |
| `<C-b>` / `<C-f>` | Full page up/down | Built-in | Standard vim motions, work in Zed |
| `<C-y>` / `<C-e>` | Line up/down | Built-in | Standard vim motions, work in Zed |
| `zt` / `zz` / `zb` | Cursor to top/center/bottom | Built-in | Standard vim motions, work in Zed |

### A.25 Text Objects (Treesitter)

| NeoVim Key | NeoVim Action | Zed Vim Built-in | Notes |
|---|---|---|---|
| `af` / `if` | Around/inside function | `a f` / `i f` | Built-in |
| `ac` / `ic` | Around/inside class | `a c` / `i c` | Built-in |
| `aa` / `ia` | Around/inside parameter | `a a` / `i a` | Built-in |
| `at` / `it` | Around/inside HTML tag | `a t` / `i t` | Built-in |
| `gc` | Comment text object | `g c` | Built-in |

### A.26 Incremental Selection

| NeoVim Key | NeoVim Action | Zed Action | keymap.json Entry |
|---|---|---|---|
| `<C-Enter>` (n) | Start selection | `editor::SelectLargerSyntaxNode` | `{"context":"vim_mode == normal","bindings":{"ctrl-enter":"editor::SelectLargerSyntaxNode"}}` |
| `<C-Enter>` (v) | Expand node | `editor::SelectLargerSyntaxNode` | `{"context":"vim_mode == visual","bindings":{"ctrl-enter":"editor::SelectLargerSyntaxNode"}}` |
| `<C-Backspace>` (v) | Shrink node | `editor::SelectSmallerSyntaxNode` | `{"context":"vim_mode == visual","bindings":{"ctrl-backspace":"editor::SelectSmallerSyntaxNode"}}` |

### A.27 Insert Mode

| NeoVim Key | NeoVim Action | Zed Action | Notes |
|---|---|---|---|
| `<Tab>` | Smart completion/snippet | `editor::Tab` | Built-in completion behavior |
| `<S-Tab>` | Prev completion/snippet | `editor::TabPrev` | Built-in |
| `<C-e>` | Close completion menu | `editor::ContextMenuDismiss` | Built-in |
| `<C-l>` (insert) | Accept AI completion | `editor::AcceptInlineCompletion` | `{"context":"vim_mode == insert","bindings":{"ctrl-l":"editor::AcceptInlineCompletion"}}` |

### A.28 Multi-cursor (Zed vim built-in, maps to NeoVim concepts)

| NeoVim Key | NeoVim Action | Zed Vim Equivalent | Notes |
|---|---|---|---|
| `<leader>sw` | Find word under cursor | `g l` (add cursor at next match) | Vim: `g l` adds cursor at next occurrence |
| N/A | N/A | `g L` (add cursor at prev match) | No NeoVim equivalent -- this is Zed-native |
| N/A | N/A | `g a` (select all matches) | No NeoVim equivalent |

---

## Section B: NOT Possible in Zed

### B.1 Instant Actions

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>n` | Notification History (Snacks) | Zed has no notification history panel/picker |
| `<leader>N` | Neovim News | NeoVim-specific, irrelevant in Zed |
| `<leader>.` | Scratch Buffer (Snacks) | Zed has no scratch buffer concept (could use `workspace::NewFile` as partial workaround) |
| `<leader>S` | Select Scratch Buffer | Same as above |

### B.2 AI Group -- `<leader>a`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>ae` | Explain code (visual select) | CodeCompanion-specific. Zed inline assist exists but no dedicated "explain" action |
| `<leader>af` | Fix code (visual select) | CodeCompanion-specific. No dedicated "fix" action in Zed |
| `<leader>at` | Generate tests (visual) | CodeCompanion-specific. No dedicated "generate tests" action |
| `<leader>ar` | Review code (visual) | CodeCompanion-specific. No code review action in Zed |
| `<leader>aV` | Virtual text ON (force enable) | Zed only has a toggle, no "force on" |
| `<leader>ax` | Virtual text OFF (force disable) | Zed only has a toggle, no "force off" |
| `<M-]>` / `<M-[>` (insert) | Next/prev Windsurf suggestion | Windsurf/Codeium-specific. Zed has its own edit prediction (Zeta) |
| `<M-c>` (insert) | Clear Windsurf suggestion | Windsurf/Codeium-specific |

### B.3 Buffer Group -- `<leader>b`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>bp` | Pick buffer by letter overlay | Zed has no letter-overlay buffer picker (like `bufferline` pick mode) |

### B.4 Code Group -- `<leader>c`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>cD` | Toggle diagnostics inline | Zed diagnostics are controlled in settings, no single toggle action for inline display |

### B.5 Debug Group -- `<leader>d` (ENTIRE GROUP)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>db` | Toggle breakpoint | Zed has breakpoints in gutter (`gutter.breakpoints: true`) but DAP integration is limited. No `dap::ToggleBreakpoint` action. **Partial**: Zed added basic debug support but it is still early-stage. |
| `<leader>dB` | Conditional breakpoint | Not available |
| `<leader>dc` | Continue | Limited DAP support |
| `<leader>dr` | Open REPL | No DAP REPL |
| `<leader>dl` | Run last debug | No DAP "run last" |
| `<leader>dh` | Hover variables | No DAP variable hover |
| `<leader>dp` | Preview variable | No DAP preview |
| `<leader>df` | Frames | No call stack frame browser |
| `<leader>ds` | Scopes | No variable scope browser |
| `<leader>dq` | Quit debug | No DAP session management |
| `<leader>du` | Toggle debug UI | No DAP UI panels |
| `<leader>de` | Eval expression | No DAP eval |
| `<leader>dP` | Toggle Profiler (Snacks) | NeoVim-specific Lua profiler |
| `<leader>dO` | Toggle Profiler Highlights | NeoVim-specific |
| `<leader>dS` | Profiler Scratch Buffer | NeoVim-specific |
| `<F5>` | Debug: Start/Continue | Limited/no DAP |
| `<F10>` | Debug: Step Over | Limited/no DAP |
| `<F11>` | Debug: Step Into | Limited/no DAP |
| `<F12>` | Debug: Step Out | Limited/no DAP |

> **Note:** Zed has been adding debug adapter support. Some basic breakpoint/run functionality may exist by now, but it is nowhere near the full nvim-dap experience. Check `debugger::` actions in the command palette.

### B.6 Find Group -- `<leader>f`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>fg` | Find git files | Zed file finder doesn't have a "git files only" filter |
| `<leader>fc` | Find config files | NeoVim-specific (searches Neovim config directory) |
| `<leader>fp` | Projects (switch project) | Zed has `recent_projects::OpenRecent` but no multi-project switcher like Snacks |

### B.7 Git Group -- `<leader>g`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>gg` | Lazygit (full TUI) | External terminal TUI; not embeddable in Zed. Use terminal panel instead. |
| `<leader>gl` | Git log | No built-in git log viewer |
| `<leader>gL` | Git log (current line) | No per-line git log |
| `<leader>gS` | Git stash | No stash management |
| `<leader>gf` | Git log file | No file-specific git log |
| `<leader>gi` | GitHub Issues (open) | No GitHub issue browser (NeoVim uses `gh` CLI via Snacks) |
| `<leader>gI` | GitHub Issues (all) | Same |
| `<leader>gp` | GitHub PRs (open) | No GitHub PR browser |
| `<leader>gP` | GitHub PRs (all) | Same |
| `<leader>ghS` | Stage entire buffer | No "stage buffer" action (only hunk-level) |
| `<leader>ghR` | Reset entire buffer | No "reset buffer" action |
| `<leader>ghu` | Undo last stage | No undo-stage action |
| `<leader>ghi` | Preview hunk inline | `editor::ToggleHunkDiff` is close but not identical |
| `<leader>ghd` | Diff this (side-by-side) | No side-by-side diff viewer like diffview.nvim |
| `<leader>ghD` | Diff this ~ (against last commit) | Same |
| `<leader>ghq` | Hunks to quickfix | No quickfix list in Zed |
| `<leader>ghQ` | All hunks to quickfix | Same |
| `<leader>gvv` | Open diffview | No diffview equivalent |
| `<leader>gvx` | Close diffview | Same |
| `<leader>gvh` | File history (diffview) | No file history diff view |
| `<leader>gvH` | Branch history (diffview) | Same |

### B.8 LSP/Lint Group -- `<leader>l`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>lc` | Clear diagnostics | No manual diagnostic clearing action |
| `<leader>ll` | Open none-ls log | NeoVim plugin-specific (none-ls/null-ls) |
| `<leader>li` | Show none-ls info | NeoVim plugin-specific |

### B.9 Markdown Group -- `<leader>m`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>mp` | Toggle browser preview | No browser markdown preview. Zed has built-in markdown preview (`markdown::OpenPreview`) which IS available. |
| `<leader>mr` | Toggle render-markdown | NeoVim plugin-specific (render-markdown.nvim) |

> **Partial:** `<leader>mp` CAN be mapped to `markdown::OpenPreview` for Zed's built-in preview.

### B.10 Refactor Group -- `<leader>r` (MOSTLY UNAVAILABLE)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>rr` | Select refactor | refactoring.nvim plugin; no equivalent. LSP code actions cover some refactors. |
| `<leader>re` | Extract Function | No dedicated extract function action (some LSPs offer this via code actions) |
| `<leader>rf` | Extract Function To File | Plugin-specific |
| `<leader>rv` | Extract Variable | No dedicated action (some LSPs offer via code actions) |
| `<leader>ri` | Inline Variable | Plugin-specific |
| `<leader>rI` | Inline Function | Plugin-specific |
| `<leader>rb` | Extract Block | Plugin-specific |
| `<leader>rbf` | Extract Block To File | Plugin-specific |
| `<leader>rp` | Debug Print Variable | Plugin-specific (refactoring.nvim) |
| `<leader>rP` | Debug Printf | Plugin-specific |
| `<leader>rc` | Debug Cleanup | Plugin-specific |

> **Partial workaround:** Many refactoring operations are available through LSP code actions (`editor::ToggleCodeActions`). For example, rust-analyzer and TypeScript LSP both offer "Extract to function" and "Extract to variable" as code actions.

### B.11 Search Group -- `<leader>s` (partial)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>sR` | Search & Replace (current file) | Zed search/replace is project-wide; no single-file mode via action |
| `<leader>s"` | Registers browser | No register browser in Zed |
| `<leader>s/` | Search history | No search history browser |
| `<leader>sa` | Autocmds browser | NeoVim-specific concept |
| `<leader>sh` | Help pages | No built-in help pages (Zed docs are in browser) |
| `<leader>sH` | Highlights browser | NeoVim-specific (highlight groups) |
| `<leader>si` | Icons picker | NeoVim-specific (Nerd Font icon picker) |
| `<leader>sj` | Jumps browser | No jump list browser |
| `<leader>sk` | Keymaps browser | Zed has keymap editor (`zed::OpenKeymap`) but no fuzzy search of keymaps |
| `<leader>sl` | Location list | No location list in Zed |
| `<leader>sm` | Marks browser | No marks browser (vim marks work but no picker) |
| `<leader>sM` | Man pages | NeoVim-specific |
| `<leader>sp` | Plugin spec | NeoVim-specific (lazy.nvim) |
| `<leader>sq` | Quickfix list | No quickfix list in Zed (use diagnostics panel instead) |
| `<leader>su` | Undo history | No visual undo tree |

### B.12 Test Group -- `<leader>t` (partial)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>tf` | Run file tests | No "run all tests in file" action (gutter runnables work per-test) |
| `<leader>ts` | Toggle test summary | No test result sidebar like neotest |
| `<leader>to` | Show test output | Test output goes to terminal, no dedicated panel |
| `<leader>tp` | Output panel | No dedicated test output panel |
| `<leader>td` | Debug test | No test-debug integration |
| `<leader>tS` | Stop running test | No test cancellation action |

### B.13 UI Toggles -- `<leader>u` (partial)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>us` | Toggle spelling | No spell check toggle action |
| `<leader>ud` | Toggle dim inactive | No dim-inactive feature |
| `<leader>uc` | Toggle conceal | NeoVim-specific (conceal level) |
| `<leader>uT` | Toggle treesitter highlight | No treesitter highlight toggle |
| `<leader>ux` | Toggle treesitter context | No sticky context/breadcrumb toggle (Zed has breadcrumbs but no toggle) |
| `<leader>uH` | Toggle colorizer | NeoVim plugin (nvim-colorizer); Zed has `color-highlight` extension but no toggle action |
| `<leader>ua` | Toggle animations | No animation toggle |

### B.14 Save + Session -- `<leader>w`

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<leader>wr` | Restore session | Zed auto-restores sessions; no manual session management |
| `<leader>ws` | Save session | Zed handles sessions automatically |
| `<leader>wd` | Delete session | No session management |
| `<leader>wf` | Find sessions | No session picker |

### B.15 YAML & K8s Group -- `<leader>y` (ENTIRE GROUP)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| All `<leader>y*` keys | YAML path navigation, schema selection, K8s CRDs | yaml.nvim, yaml-companion, kubernetes.nvim are all NeoVim-specific plugins with no Zed equivalent. Zed has YAML LSP support for schema validation but no interactive path navigation, yank-path, or CRD management. |

### B.16 Language-Specific Groups

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| All `<leader>G*` (Go) | Go tags, mod, generate, if-err, etc. | go.nvim plugin-specific. No equivalent in Zed. LSP code actions cover some (like "Generate method stubs"). |
| All `<leader>R*` (Rust) | Expand macro, runnables, debuggables, crates.nvim | rustaceanvim/crates.nvim specific. Zed's rust-analyzer integration provides some via code actions and gutter runnables, but no dedicated UI. |

### B.17 Non-Leader: Flash Navigation

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `s` (n,x,o) | Flash jump (type 2 chars) | No flash.nvim equivalent. Zed has `vim::PushSneak` (optional, 2-char search like vim-sneak) which is close. Enable: `{"context":"vim_mode == normal","bindings":{"s":"vim::PushSneak","shift-s":"vim::PushSneakBackward"}}` |
| `S` (n,x,o) | Flash treesitter (select node) | No syntax-node-based jump |
| `r` (operator-pending) | Remote flash | No equivalent |
| `R` (o,x) | Treesitter search | No equivalent |
| `<C-s>` (command) | Toggle flash in search | No equivalent |

> **Partial:** Zed vim has `vim::PushSneak` and `vim::PushSneakBackward` which provide 2-character search similar to vim-sneak (a subset of flash.nvim functionality).

### B.18 Non-Leader: Bracket Navigation (partial)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `[t` / `]t` | Prev/next TODO comment | No TODO comment navigation |
| `[T` / `]T` | Prev/next failed test | No test failure navigation |
| `[q` / `]q` | Prev/next quickfix | No quickfix list |
| `[e` / `]e` | Prev/next error | Could map to `editor::GoToPrevDiagnostic`/`editor::GoToNextDiagnostic` (partial -- these include warnings too) |
| `[w` / `]w` | Prev/next warning | No warning-specific navigation |
| `[x` | Jump to treesitter context | `[ x` selects larger syntax node (different behavior) |
| `[c` / `]c` | Prev/next class start | No class-specific navigation (Zed `[c`/`]c` is git hunks) |
| `[C` / `]C` | Prev/next class end | No class end navigation |
| `[i` / `]i` | Prev/next conditional | No conditional navigation |
| `[I` / `]I` | Prev/next conditional end | Same |
| `[l` / `]l` | Prev/next loop | No loop navigation |
| `[L` / `]L` | Prev/next loop end | Same |
| `[a` / `]a` | Swap parameter prev/next | No parameter swap |

### B.19 Non-Leader: Yank History

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<C-p>` / `<C-n>` | Cycle yank history | No yank ring/history in Zed (yanky.nvim specific). Zed uses system clipboard. Vim registers (`"1` through `"9`) work for delete history. |

### B.20 Non-Leader: Smooth Scrolling

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `zt` / `zz` / `zb` (smooth) | Smooth scroll to position | Zed scrolls instantly (no animation library like Snacks.scroll). The commands themselves work, just not animated. |

### B.21 Fold Preview

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `zK` | Peek fold preview (ufo.nvim) | No fold preview/peek in Zed |

### B.22 Text Objects (partial)

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `ai` / `ii` | Around/inside conditional | Zed `ai`/`ii` maps to indent-level, not conditional |
| `al` / `il` | Around/inside loop | No loop text object |
| `ab` / `ib` | Around/inside block | No generic block text object (use `a {`/`i {` for braces) |
| `aC` / `iC` | Around/inside function call | No function call text object |
| `as` / `is` | Around/inside assignment | No assignment text object |
| `ak` | Assignment key (left side) | No assignment-key text object |
| `av` | Assignment value (right side) | No assignment-value text object |
| `an` | Number text object | No number text object |
| `aS` | Statement text object | No statement text object |
| `ih` | Git hunk text object | No git hunk text object |

### B.23 Terminal Navigation

| NeoVim Key | NeoVim Action | Why Not Available |
|---|---|---|
| `<C-h/j/k/l>` (terminal mode) | Window nav from terminal | Zed terminal captures these keys. Use `ctrl-w` prefix or configure terminal key forwarding. Partial: `{"context":"Terminal","bindings":{"ctrl-h":"workspace::ActivatePaneLeft"}}` may work. |

---

## Section C: Zed-specific Additions

Actions that exist in Zed but have no NeoVim equivalent. These are worth binding for a productive Zed workflow.

### C.1 Agent / AI Panel

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>aA` | `assistant::NewThread` | Start a new AI conversation thread |
| `<leader>ao` | `agent::Open` | Open the full agent panel |
| `<leader>ai` | `assistant::InlineAssist` | Inline AI transformation (works on selection or cursor) |
| `ctrl-enter` | `assistant::InlineAssist` | Quick inline assist (default Zed binding) |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space a o": "agent::Open",
    "space a a": "assistant::ToggleFocus",
    "space a shift-a": "assistant::NewThread",
    "space a i": "assistant::InlineAssist"
  }
}
```

### C.2 Multi-cursor (Zed's killer feature)

| Suggested Key | Zed Action | Description |
|---|---|---|
| `gl` | (built-in) | Add cursor at next occurrence of word |
| `gL` | (built-in) | Add cursor at previous occurrence |
| `ga` | (built-in) | Select ALL occurrences of word |
| `g>` | (built-in) | Skip current, add next occurrence |
| `g<` | (built-in) | Skip current, add previous occurrence |
| `gI` (visual) | (built-in) | Add cursor at start of each visual line |
| `gA` (visual) | (built-in) | Add cursor at end of each visual line |

These are all built into Zed vim mode -- no custom mapping needed.

### C.3 Collaboration

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>Cc` | `collab_panel::ToggleFocus` | Open collaboration panel |
| `<leader>Cs` | `workspace::ShareProject` | Share project with collaborators |
| `<leader>Cf` | `workspace::FollowNextCollaborator` | Follow a collaborator's cursor |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space shift-c c": "collab_panel::ToggleFocus",
    "space shift-c f": "workspace::FollowNextCollaborator"
  }
}
```

### C.4 Pane Management

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>sv` | `pane::SplitRight` | Split pane vertically (`:vs`) |
| `<leader>sh` | `pane::SplitDown` | Split pane horizontally (`:sp`) |
| `<C-w>gd` | (built-in) | Go to definition in split |
| `<C-w>gD` | (built-in) | Go to type definition in split |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space |": "pane::SplitRight",
    "space -": "pane::SplitDown"
  }
}
```

### C.5 Panels & Docks

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>E` | `project_panel::ToggleFocus` | File explorer |
| `<leader>T` | `terminal_panel::ToggleFocus` | Terminal |
| `<leader>G` | `git_panel::ToggleFocus` | Git panel |
| `<leader>D` | `diagnostics::Deploy` | Diagnostics panel |
| `<leader>O` | `outline_panel::ToggleFocus` | Outline/symbols panel |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space shift-e": "project_panel::ToggleFocus",
    "space shift-t": "terminal_panel::ToggleFocus",
    "space shift-g": "git_panel::ToggleFocus",
    "space shift-d": "diagnostics::Deploy",
    "space shift-o": "outline_panel::ToggleFocus"
  }
}
```

### C.6 Editor Intelligence

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>cp` | `editor::OpenPermalink` | Copy permalink to current line (GitHub) |
| `<leader>cP` | `editor::OpenPermalinkToLine` | Open permalink in browser |
| `<leader>cd` | `editor::ToggleHunkDiff` | Toggle inline diff for current hunk |
| `<leader>cg` | `editor::ToggleGitBlame` | Toggle git blame |

### C.7 Workspace Actions

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>p` | `projects::OpenRecent` | Open recent projects |
| `<leader>P` | `command_palette::Toggle` | Command palette (find any action) |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space p": "projects::OpenRecent",
    "space shift-p": "command_palette::Toggle"
  }
}
```

### C.8 Zed Vim-Specific Motions

These vim motions are Zed-specific and worth enabling:

```json
[
  {
    "context": "VimControl && !menu",
    "bindings": {
      "s": "vim::PushSneak",
      "shift-s": "vim::PushSneakBackward"
    }
  },
  {
    "context": "VimControl && !menu && vim_mode != operator",
    "bindings": {
      "w": "vim::NextSubwordStart",
      "b": "vim::PreviousSubwordStart",
      "e": "vim::NextSubwordEnd",
      "g e": "vim::PreviousSubwordEnd"
    }
  },
  {
    "context": "vim_mode == visual",
    "bindings": {
      "shift-s": "vim::PushAddSurrounds"
    }
  }
]
```

| Key | Action | Description |
|---|---|---|
| `s` / `S` | `vim::PushSneak` / `vim::PushSneakBackward` | 2-char search (like vim-sneak / partial flash.nvim) |
| `w` / `b` / `e` | Subword motions | CamelCase/snake_case word navigation |
| `S` (visual) | `vim::PushAddSurrounds` | Surround selection |
| `cx` | `vim::Exchange` | Exchange text (vim-exchange) |
| `gR` | Replace with register | (vim-ReplaceWithRegister) |

### C.9 Task Runner

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>tr` | `task::Spawn` | Run a task (pick from tasks.json) |
| `<leader>tR` | `task::Rerun` | Re-run the last task |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space t r": "task::Spawn",
    "space t shift-r": "task::Rerun"
  }
}
```

### C.10 Markdown Preview

| Suggested Key | Zed Action | Description |
|---|---|---|
| `<leader>mp` | `markdown::OpenPreview` | Open side-by-side markdown preview |
| `<leader>mP` | `markdown::OpenPreviewToTheSide` | Preview in split |

```json
{
  "context": "vim_mode == normal",
  "bindings": {
    "space m p": "markdown::OpenPreview",
    "space m shift-p": "markdown::OpenPreviewToTheSide"
  }
}
```

### C.11 Edit Predictions (Zeta)

| Suggested Key | Zed Action | Description |
|---|---|---|
| `tab` (insert) | `editor::AcceptEditPrediction` | Accept the current edit prediction |
| `alt-]` (insert) | `editor::NextEditPrediction` | Cycle to next prediction |
| `alt-[` (insert) | `editor::PreviousEditPrediction` | Cycle to previous prediction |

These are Zed's AI-powered multi-line edit predictions -- a feature NeoVim doesn't have natively.

---

## Summary Statistics

| Category | Count |
|---|---|
| **Total NeoVim keybindings analyzed** | ~220+ |
| **Mappable in Zed (Section A)** | ~95 |
| **NOT possible in Zed (Section B)** | ~125 |
| **Zed-specific additions (Section C)** | ~35 |

### Key Takeaways

1. **Core editing is well-covered**: LSP navigation (`gd`, `gr`, `gI`, `gy`), comments (`gcc`, `gc`), surround (`ys`, `cs`, `ds`), text objects (`af`, `ac`, `aa`, `at`), and standard vim motions all work out of the box.

2. **Biggest gaps are in plugins**: Debug (DAP), refactoring.nvim, flash.nvim, Snacks pickers, diffview.nvim, lazygit, and language-specific plugins (go.nvim, rustaceanvim, crates.nvim, yaml.nvim) have no equivalents. These represent ~60% of the unmappable bindings.

3. **Zed's unique strengths**: Multi-cursor (`gl`, `ga`, `gA`), built-in AI agent, collaboration, edit predictions (Zeta), and tasks.json are areas where Zed offers capabilities NeoVim requires plugins for (or cannot do at all).

4. **Git is partial**: Basic hunk navigation and staging works, but no lazygit, no diffview, no GitHub issue/PR browsing, no stash management.

5. **Which-key works**: Zed's `which_key` setting enables the leader key popup, making space-prefixed bindings discoverable just like in NeoVim.
