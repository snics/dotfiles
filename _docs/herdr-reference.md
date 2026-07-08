# herdr — Funktions- & Keybinding-Referenz

herdr 0.7.3 · macOS · Ghostty als Host · Prefix **`Ctrl+Space`**.
Quellen: Deep-Research (herdr.dev/docs, GitHub-Changelog 0.7.x, Ghostty-Docs,
adversarial verifiziert 25/25) plus lokale Primärdaten (Plugin-Manifeste via
`herdr plugin action list` und `herdr-plugin.toml`, Ghostty-Defaults via
`ghostty +list-keybinds`). Stand 2026-07-08.

## Grundmechanik (verifiziert)

- Aktionen werden in `~/.config/herdr/config.toml` unter `[keys]` als
  `aktion = "prefix+X"` gebunden; eigene Kommandos über `[[keys.command]]`
  mit `type = "pane" | "shell" | "plugin_action"`.
- Plugin-Aktionen haben global qualifizierte IDs `plugin.id.action` und
  werden per `type = "plugin_action"` auf Tasten gelegt.
- **Ab 0.7.1**: eigene Bindings verdrängen kollidierende Defaults sauber
  (kein Doppel-Binding). Rohes `Ctrl+V` wird lokal nicht mehr abgefangen
  (Vim-Block-Visual funktioniert).
- **`prefix+X`-Slots kollidieren nie mit Ghostty** — Ghostty sieht nur den
  Prefix, danach fängt herdr alles ab. Nur direkte `cmd/ctrl/alt+X`-Chords
  müssen gegen Ghostty geprüft werden.

## herdr-Kern-Aktionen

| Funktion | Action-ID | Aktuelles Binding |
|---|---|---|
| Split rechts | `split_vertical` | `prefix+\|` |
| Split unten | `split_horizontal` | `prefix+-` |
| Pane-Fokus l/u/o/r | `focus_pane_*` | leer (via `Ctrl+hjkl`) |
| Letztes Pane | `last_pane` | `prefix+;` |
| Pane zoomen | `zoom` | `prefix+z` |
| Pane schließen | `close_pane` | `prefix+x` |
| Resize-Mode | `resize_mode` | `prefix+r` (Default) |
| Scrollback im Editor | `edit_scrollback` | `prefix+v` |
| Neuer Tab | `new_tab` | `prefix+c` |
| Tab wechseln | `switch_tab` | `prefix+1..9` (Default) |
| Tab vor/zurück | `next_tab`/`previous_tab` | `prefix+n`/`p` |
| Workspace direkt | `switch_workspace` | `cmd+1..9` |
| Workspace vor/zurück | `next_/previous_workspace` | `prefix+]`/`[` |
| Neuer Workspace | `new_workspace` | `prefix+shift+n` |
| Workspace-Picker | `workspace_picker` | `prefix+w` |
| Goto-Picker | `goto` | `prefix+'` |
| Agent direkt | `focus_agent` | `cmd+shift+1..9` |
| Agent vor/zurück | `next_/previous_agent` | `prefix+a`/`shift+a` |
| Zur Notification springen | (Default) | `prefix+o` |
| Neuer Worktree | `new_worktree` | leer (→ sessionizer, `prefix+shift+g`) |
| Worktree öffnen | `open_worktree` | `prefix+shift+o` |
| Worktree entfernen | `remove_worktree` | **leer (bewusst — destruktiv, nur Menü)** |
| Sidebar toggeln | `toggle_sidebar` | `prefix+b` |
| Settings | `settings` | `prefix+,` |
| Detach | `detach` | `prefix+q` |
| Config neu laden | (Default) | `prefix+shift+r` |
| Hilfe | (Default) | `prefix+?` |

## Plugins — Aktionen (lokal aus den Manifesten verifiziert)

| Plugin | Aktion (`plugin.id.action`) | Binding | Interne Tasten |
|---|---|---|---|
| **herdr-splits** | `herdr-splits.nav-{left,down,up,right}` | `Ctrl+h/j/k/l` | Zahl-Präfix (`3 Ctrl+h`), Auto-Unzoom |
| | `herdr-splits.resize-{left,down,up,right}` | `Alt+h/j/k/l` | — |
| **lazygit-overlay** | `beomjungil.lazygit-overlay.open` | `prefix+g` / `Cmd+g` | (lazigit-eigene Tasten im Overlay) |
| **fzf-url** | `url.fzf-picker.pick-url` | `prefix+u` | fzf: Tippen filtert, Enter öffnet |
| **reviewr** | `persiyanov.reviewr.toggle` | `Cmd+r` | `1/2/3` Tabs · `u/b/t` Scope · `j/k` · `Tab` Fokus · `v` Select · `c` Kommentar · `s` senden · `y` kopieren |
| **token-dashboard** | `dave.token-dashboard.open-dashboard` | `prefix+$` | `q/esc` schließen · `r` refresh |
| **file-viewer** | `herdr-file-viewer.open-file-viewer` | `Cmd+o` | `f` Fuzzy · `/` `n/N` Suche · `:` Goto-Line · `v` View · `z` Zoom · `W` Worktree · `?` Hilfe |
| | `herdr-file-viewer.open-file-viewer-tab` | `Cmd+shift+o` | — |
| **herdr-plus** | `cloudmanic.herdr-plus.projects` | (via Aktionsmenü) | Picker: Enter=Workspace, `Ctrl+g`=Worktree |
| | `cloudmanic.herdr-plus.quick-actions` | `prefix+.` | Fuzzy-Liste |
| **sessionizer** | `sessionizer.open` | `Cmd+p` | Picker: Enter fokussiert/erstellt, Esc→Projekte |
| | `sessionizer.worktree-open` | `prefix+shift+g` | Branch-Picker (lokal/remote/neu) |
| **renamer** | (kein User-Action — `event pane.agent_status_changed`) | — | läuft automatisch |

**nvim-seitig (herd.nvim):** `<leader>\` Agent-Float toggeln (visuell:
Selektion senden) · `<leader>ah` Picker · `<leader>aH` Dashboard.

## Freie Slots (geprüft)

**`prefix+X` — alle frei & Ghostty-sicher:** `d, e, i, j, m, y, /` u. a.
Aktuell belegt: `q w g(') n c z x r b v , ; [ ] a f s k u $ . | - o t p d? 1..9`.

**Direkte `Cmd+X` — gegen Ghostty geprüft:**

| Slot | Status |
|---|---|
| `cmd+u` `cmd+y` `cmd+i` `cmd+m` `cmd+b` | ✅ frei |
| `cmd+e` | ❌ Ghostty `search_selection` |
| `cmd+j` | ❌ Ghostty `scroll_to_selection` |
| `cmd+t` | ❌ Ghostty `new_tab` |

## Bewertung: Was ist noch offen zu binden?

Das Setup ist **praktisch vollständig gemappt**. Wirklich unbelegte, aber
bindbare Funktionen:

1. `remove_worktree` — bewusst leer (destruktiv). Falls gewünscht: `prefix+y`.
2. `herdr-plus.projects` — liegt aktuell nur im Aktionsmenü (sessionizer
   deckt den Picker-Fall über `Cmd+p` ab). Optional auf eigene Taste, z. B.
   `prefix+shift+p`, falls du die kuratierten Templates direkt willst.
3. Alle übrigen Kern-/Plugin-Aktionen sind gebunden.

## Widersprüche Doku ↔ 0.7.3 (aus dem Report)

- Web-Suchindizes meldeten teils 0.7.1 — **0.7.3 ist maßgeblich** (Live-GitHub).
- Report nannte `copy_mode = prefix+[` als Default — in der tatsächlichen
  0.7.3-`--default-config` existiert **kein** `copy_mode`; `prefix+[` ist
  also frei und liegt bei uns konfliktfrei auf `previous_workspace`.
  Scrollback nutzen wir über `edit_scrollback` (`prefix+v`).
- Kein Top-Level `herdr config`-Kommando — Config nur über Dateien +
  `herdr config reset-keys`.
- Socket-Transport ist newline-delimited JSON (nicht strikt JSON-RPC-Spec);
  Methodennamen (`pane.send_keys`, `plugin.action.invoke`) stimmen.
