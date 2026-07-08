# herdr — Plugin- & Ökosystem-Übersicht

Stand: 2026-07-07. Quellen: offizieller Marketplace-Index (GitHub-Topic
[`herdr-plugin`](https://github.com/topics/herdr-plugin), 113 Repos) und
[awesome-herdr](https://github.com/yigitkonur/awesome-herdr).
Installation: `herdr plugin install <owner>/<repo>`.

**Bereits installiert:** ✅ `vim-herdr-navigation`, ✅ `herdr-fzf-url`,
✅ `herdr-lazygit-overlay`, ✅ `herdr-reviewr` (`Cmd+r`), dazu die Integrationen
`claude` + `opencode` + `codex` (`herdr integration install …`) und das
offizielle Agent-SKILL.md (`npx skills add ogulcancelik/herdr --skill herdr -g`).

Sterne (⭐) vom 2026-07-07 — bei so einem jungen Ökosystem eher ein Signal
für Momentum als für Reife.

## Navigation & Fokus

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ✅ [paulbkim-dev/vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) | 24 | Ctrl+h/j/k/l nahtlos zwischen herdr-Panes und Vim/NeoVim-Splits (vim-tmux-navigator-Port) |
| [lmilojevicc/herdr-splits.nvim](https://github.com/lmilojevicc/herdr-splits.nvim) | 11 | Smart-Splits-Navigation **und Resizing** für herdr + NeoVim (Alternative zu vim-herdr-navigation) |
| [willfish/herdr-navigator](https://github.com/willfish/herdr-navigator) | 0 | Noch eine Vim-aware Pane-Navigation (herdr-Seite) |
| [ycros/herdr-compass](https://github.com/ycros/herdr-compass) | 0 | Einheitliche Richtungsnavigation über Panes, Tabs UND Workspaces |
| [agustinvalencia/herdr-jump](https://github.com/agustinvalencia/herdr-jump) | 0 | Overlay-Picker für Spaces und Agents mit Live-Statusfarben |
| [third774/herdr-last-workspace](https://github.com/third774/herdr-last-workspace) | 5 | Toggle zum zuletzt fokussierten Workspace (wie tmux `last-window`) |
| [dantehemerson/herdr-last-tab](https://github.com/dantehemerson/herdr-last-tab) | 0 | Toggle zum zuletzt fokussierten Tab |
| [AVGVSTVS96/herdr-tab-mover](https://github.com/AVGVSTVS96/herdr-tab-mover) | 0 | Tabs in andere Workspaces verschieben |

## Workspaces, Sessions & Picker

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ⏸️ [yuk1ty/herdr-spreader](https://github.com/yuk1ty/herdr-spreader) | 28 | Komplettes Multi-Workspace-Layout aus einer YAML hochziehen (tmuxinator-Prinzip; Split-Ratios, Env-Vars, `wait_for`-Synchronisation). **Bewusst zurückgestellt:** ~80 % Überschneidung mit herdr-plus; nur nachrüsten, wenn ein Projekt echte Service-Startreihenfolgen braucht |
| ✅ [andrewchng/herdr-sessionizer](https://github.com/andrewchng/herdr-sessionizer) | 15 | Fuzzy Projekte/Worktrees öffnen (`Cmd+p` / `Prefix+Shift+g`), Roots-Globs über ~/Projects, Default-Layout claude+lazygit+terminal; Config versioniert im herdr-Package |
| [JanTvrdik/herdr-command-palette](https://github.com/JanTvrdik/herdr-command-palette) | 9 | fzf-Kommandopalette über alle Actions aller installierten Plugins |
| [thanhdat77/herdr-picker-plus](https://github.com/thanhdat77/herdr-picker-plus) | 3 | Ein Overlay für alles: Workspaces, SSH-Server, Agents, Projekte, Verzeichnisse |
| [nikok6/herdr-mirror](https://github.com/nikok6/herdr-mirror) | 6 | Remote-herdr-Server in die lokale Sidebar spiegeln und über SSH steuern |
| [ntindle/herdr-resurrect](https://github.com/ntindle/herdr-resurrect) | 1 | tmux-resurrect für herdr: Snapshot + Restore nach Crash/Reboot |
| [iviaxpow3r/herdr-session-parker](https://github.com/iviaxpow3r/herdr-session-parker) | 2 | Panes/Tabs "parken" und Agent-Sessions später fortsetzen |
| [lmilojevicc/seshagy](https://github.com/lmilojevicc/seshagy) | 2 | Agent-aware Session-Manager für tmux **und** herdr (interessant für deinen Dual-Setup!) |
| [marcoskichel/herdr-muster](https://github.com/marcoskichel/herdr-muster) | 2 | Agent-aware Projekt-Switcher |
| [sohanemon/herdr-helpr](https://github.com/sohanemon/herdr-helpr) | 4 | Prompt-gesteuerte Workspace-/Pane-Verwaltung, Aufräumhilfen |
| [wilbeibi/herdr-catchup](https://github.com/wilbeibi/herdr-catchup) | 0 | Agent-Sessions nachlesen, forken und übergeben |
| [nicolasvasquez/herdr-smart-workspace](https://github.com/nicolasvasquez/herdr-smart-workspace) | 0 | Workspace-Switch/-Erstellung aus zoxide per fzf-Overlay |
| [den-tanui/herdr-zoxide](https://github.com/den-tanui/herdr-zoxide) | 1 | Workspaces/Tabs/Panes aus zoxide-Verzeichnissen erzeugen |
| [willfish/herdr-workspacex](https://github.com/willfish/herdr-workspacex) | 0 | Rust-nativer Fuzzy-Workspace-Switcher mit zoxide-Backend |
| [yoshiori/herdr-configurable-picker](https://github.com/yoshiori/herdr-configurable-picker) | 1 | Baumbasierter Goto-Picker mit frei konfigurierbaren Keybindings |
| [alon-z/herdr-command-palette](https://github.com/alon-z/herdr-command-palette) | 0 | Leichtgewichtiger Workspace-/Verzeichnis-Switcher |
| [nicolegros/herdr-launcher](https://github.com/nicolegros/herdr-launcher) | 0 | Fuzzy-Verzeichnis-Picker zum Erstellen/Wechseln von Workspaces |
| [arjenblokzijl/herdr-launcher](https://github.com/arjenblokzijl/herdr-launcher) | 0 | TOML-Workflows per Fuzzy-Picker + Formular, dann Agent in neuem Space starten |
| ✅ [cloudmanic/herdr-plus](https://github.com/cloudmanic/herdr-plus) | 72 | Projekt-Templates (deklarative Workspace-Vorlagen, `Cmd+p`) + Quick-Action-Launcher (`Prefix+.`); Templates in `plugins/config/cloudmanic.herdr-plus/projects/` |

## Git-Worktrees

| Plugin | ⭐ | Was es tut |
|---|---|---|
| [NathanFlurry/herdr-plugin-jj-workspace](https://github.com/NathanFlurry/herdr-plugin-jj-workspace) | 22 | Jujutsu-(jj)-Workspaces als herdr-Workspaces anlegen/entfernen |
| [devashish2203/herdr-worktrunk](https://github.com/devashish2203/herdr-worktrunk) | 17 | Worktrunk-Integration für Worktree-Management |
| [razajamil/herdr-plugin-workspace-manager](https://github.com/razajamil/herdr-plugin-workspace-manager) | 11 | Deklarative Tab-/Pane-Layouts, automatisch angewendet bei Worktree-Erstellung |
| [tdi/herdr-worktree-setup](https://github.com/tdi/herdr-worktree-setup) | 5 | Setup-Schritte bei Worktree-Erstellung (.env kopieren, mise trust, direnv, deps) |
| [tdi/herdr-worktree-from-pr](https://github.com/tdi/herdr-worktree-from-pr) | 3 | Worktree aus GitHub-PR erzeugen und als Workspace öffnen |
| [tdi/herdr-worktree-from-linear](https://github.com/tdi/herdr-worktree-from-linear) | 1 | Worktree aus Linear-Issue erzeugen |
| [persiyanov/herdr-fresh-worktree](https://github.com/persiyanov/herdr-fresh-worktree) | 1 | Neue Worktrees auf origin-Default-Branch zurücksetzen |
| [shizlie/herdr-setup-bootstrap](https://github.com/shizlie/herdr-setup-bootstrap) | 2 | Worktree-Bootstrap aus `worktree_init.toml` |
| [hmu332233/herdr-symlink-worktree](https://github.com/hmu332233/herdr-symlink-worktree) | 1 | Geteilte lokale Dateien vom Haupt-Repo in neue Worktrees symlinken |
| [freethinkel/herdr-plugin-git-worktree-hooks](https://github.com/freethinkel/herdr-plugin-git-worktree-hooks) | 1 | Shell-Hooks bei Worktree create/remove, eine YAML für alle Projekte |
| [jlimas/herdr-worktree-seed](https://github.com/jlimas/herdr-worktree-seed) | 0 | node_modules (copy-on-write) + .env in neue Worktrees seeden |
| [Feasy01/herdr-allow](https://github.com/Feasy01/herdr-allow) | 0 | Gitignorierte Dateien (.env, Secrets) per Allowlist in Worktrees kopieren |
| [qdentity/herdr-worktree-lifecycle](https://github.com/qdentity/herdr-worktree-lifecycle) | 0 | Worktree-Lifecycle-Events an repo-eigene Setup-/Teardown-Skripte dispatchen |
| [arjenblokzijl/herdr-worktree-provisioner](https://github.com/arjenblokzijl/herdr-worktree-provisioner) | 0 | Per-Repo-Setup im eigenen sichtbaren Pane des neuen Worktrees |
| [langtind/gren-herdr](https://github.com/langtind/gren-herdr) | 0 | Worktrees via gren erstellen/wechseln/entfernen |
| [kbrdn1/herdr-plugin-gwm](https://github.com/kbrdn1/herdr-plugin-gwm) | 0 | gwm als Source of Truth für Worktrees, herdr adoptiert |
| [EzraCerpac/jj-waltz](https://github.com/EzraCerpac/jj-waltz) | 2 | Jujutsu-Workspace-Switcher (Worktrunk-inspiriert) |
| [dutifuldev/herdr-branch-cleanup](https://github.com/dutifuldev/herdr-branch-cleanup) | 2 | Auto-Checkout des Default-Branch, wenn der Pane-Branch gemergt/gelöscht wurde |

## Git & GitHub im Terminal

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ✅ [smarzban/herdr-file-viewer](https://github.com/smarzban/herdr-file-viewer) | 53 | Git-aware Read-only-Dateibetrachter: Tree + Diffs + Markdown + Syntax-Highlighting (`Cmd+o`; Rolle: Überblick — reviewr bleibt fürs Kommentieren) |
| ✅ [persiyanov/herdr-reviewr](https://github.com/persiyanov/herdr-reviewr) | 29 | Code-Review-Sidebar: Agent-Änderungen reviewen, Zeilenkommentare zurück in den Chat (`Cmd+r`) |
| [dutifuldev/ghzinga](https://github.com/dutifuldev/ghzinga) | 24 | Klickbare TUI für einzelne GitHub-Issues/PRs |
| [ogulcancelik/herdr-plugin-github-start](https://github.com/ogulcancelik/herdr-plugin-github-start) | 5 | Codex/Claude direkt aus GitHub-Issue, PR oder Discussion starten |
| [wyattjoh/herdr-plugin-gh-pr](https://github.com/wyattjoh/herdr-plugin-gh-pr) | 2 | PR-Status des fokussierten Agent-Branch in der Sidebar |
| [edmundmiller/herdr-plugin-hunk](https://github.com/edmundmiller/herdr-plugin-hunk) | 2 | Hunk-Diffs in Splits oder Tabs öffnen |
| [scott306lr/herdr-plugin-hunk-autodiff](https://github.com/scott306lr/herdr-plugin-hunk-autodiff) | 0 | Auto-Diff-Split, sobald ein Agent mit uncommitteten Änderungen fertig ist |
| [Matovidlo/herdr-pr-tracker](https://github.com/Matovidlo/herdr-pr-tracker) | 0 | Trackt den PR jeder Claude-Code-Session mit gh-Status + Actions |
| [juninaba/herdr-pr-preview](https://github.com/juninaba/herdr-pr-preview) | 0 | PR des aktuellen Branch im Split-Pane previewen |
| [kkckkc/herdr-plugin-gh-workflow](https://github.com/kkckkc/herdr-plugin-gh-workflow) | 1 | Issue → Branch → Worktree → Workspace als ein Flow |
| [krystof018/herdr-git-status](https://github.com/krystof018/herdr-git-status) | 1 | CI-Status-Punkte für GitLab und GitHub |
| [blurname/herdr-git-tab-name](https://github.com/blurname/herdr-git-tab-name) | 0 | Tabs nach Git-Branch des fokussierten Panes benennen |
| [edmundmiller/…github-link-preview](https://github.com/edmundmiller/herdr-plugin-dotfiles-github-link-preview) | 1 | GitHub-Issues/PRs in einem Seiten-Pane previewen |

## Notifications & Remote-Steuerung

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ❌ [dcolinmorgan/herdr-remote](https://github.com/dcolinmorgan/herdr-remote) | 35 | Agents vom Handy/Menübar/Telegram freigeben. **Bewusst nicht installiert:** Remote-Terminal-Input hinter Shared Secret über öffentlichen Cloudflare-Tunnel, Web-App fremdgehostet, keine Lizenz. Bei Bedarf stattdessen Tailscale + collie oder offizielles `herdr --remote` via SSH |
| [cobanov/herdr-ntfysh](https://github.com/cobanov/herdr-ntfysh) | 8 | ntfy-Push, wenn ein Agent fertig ist oder Input braucht |
| [zom-2018/herdr-ntfy-notify](https://github.com/zom-2018/herdr-ntfy-notify) | 4 | ntfy-Push in Echtzeit (Alternative) |
| [horn553/herdr-ntfy](https://github.com/horn553/herdr-ntfy) | 1 | Minimal-ntfy (nur jq, curl, sh) |
| [yankewei/herdr-focus-notify](https://github.com/yankewei/herdr-focus-notify) | 2 | Klickbare macOS-Toasts: Klick holt Terminal nach vorn und fokussiert das richtige Pane |
| [dot/herdr-terminal-notifier](https://github.com/dot/herdr-terminal-notifier) | 1 | Anpassbare macOS-Notifications via terminal-notifier |
| [juninaba/herdr-slack-notify](https://github.com/juninaba/herdr-slack-notify) | 0 | Slack-Nachricht bei fertig/blockiert |
| [tiny-send/tinysend-herdr](https://github.com/tiny-send/tinysend-herdr) | 1 | E-Mail bei blockiert/fertig — Antwort auf die Mail entsperrt den Agent |
| [dcolinmorgan/herdr-push](https://github.com/dcolinmorgan/herdr-push) | 4 | Zero-Dependency-Event-Push an herdr-remote (Mobile-Monitoring) |
| [0cv/herdr-mobile-relay](https://github.com/0cv/herdr-mobile-relay) | 1 | Agents über mehrere Rechner hinweg vom Handy freigeben |
| [AltanS/collie](https://github.com/AltanS/collie) | 2 | PWA-Anbindung übers Tailnet, Web-Push inklusive |
| [amurru/herdr-whistle](https://github.com/amurru/herdr-whistle) | 0 | Remote-Agent-Management |

## Kosten, Telemetrie & Status

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ❌ [fkiene/llmtrim-herdr](https://github.com/fkiene/llmtrim-herdr) | 4 | Komprimiert Agent-Requests (−31 % Input / −74 % Output laut Messung), Sparbadge pro Pane. **Bewusst nicht installiert:** MITM-Proxy mit Zertifikat-Injektion, verändert API-Requests (Qualitätsrisiko), bei Subscription-Nutzung kein Spareffekt |
| ✅ [Davidcreador/herdr-token-dashboard](https://github.com/Davidcreador/herdr-token-dashboard) | 4 | Live-Token-Kosten-Dashboard + Kosten-Toasts (`Prefix+$`). Liest aktuell nur Pi-/OpenCode-Sessions |
| [astkaasa/herdr-tokscale-dashboard](https://github.com/astkaasa/herdr-tokscale-dashboard) | 1 | Tokscale-Kostendashboard als Pane |
| [0x5c0f/herdr-insight](https://github.com/0x5c0f/herdr-insight) | 2 | Agent-State-Timeline über alle Workspaces |
| [CodyBontecou/herdr-telemetry-bridge](https://github.com/CodyBontecou/herdr-telemetry-bridge) | 1 | Streamt Workspace-/Agent-/Modell-Telemetrie an externe Clients |
| [cdc-lst/herdr-wait](https://github.com/cdc-lst/herdr-wait) | 0 | Taggt idle Panes mit dem echten Wartegrund (z. B. "waiting: build-api") aus dem Prozessbaum |
| [ryonakae/shepherd](https://github.com/ryonakae/shepherd) | 0 | Observability-Daemon + Runtime-Bridges für herdr-Agents |

## Pane-Utilities & UI

| Plugin | ⭐ | Was es tut |
|---|---|---|
| ✅ [x0d7x/herdr-fzf-url](https://github.com/x0d7x/herdr-fzf-url) | 1 | URLs aus Panes scannen und per fzf öffnen |
| ✅ [beomjungil/herdr-lazygit-overlay](https://github.com/beomjungil/herdr-lazygit-overlay) | — | lazygit als Overlay über dem aktiven Pane, Fokus/Zoom werden danach wiederhergestellt |
| [rmarganti/herdr-pluck](https://github.com/rmarganti/herdr-pluck) | 6 | Pattern-gematchte Strings (SHAs, Pfade, IPs …) schnell kopieren |
| [hitaishi2222/herdr-fingers](https://github.com/hitaishi2222/herdr-fingers) | 2 | tmux-fingers-Stil: Buchstaben-Hints auf jedem kopierbaren Token |
| [Tyru5/herdr-floax](https://github.com/Tyru5/herdr-floax) | 1 | Schwebende Scratch-Shell (tmux-floax-Stil), eine pro Workspace, persistent |
| [jeromychu23/herdr-scratch-pane](https://github.com/jeromychu23/herdr-scratch-pane) | 0 | Natives gezoomtes Scratch-Pane |
| [AkashJana18/herdr-scratch](https://github.com/AkashJana18/herdr-scratch) | 0 | Persistente Scratchpads |
| [carsonjones/herdr-plugin-tiles](https://github.com/carsonjones/herdr-plugin-tiles) | 1 | Split-Ratio-Layout-Presets |
| [kamaaina/herdr_sync](https://github.com/kamaaina/herdr_sync) | 1 | Ein Kommando an alle Panes broadcasten |
| [furuhashin/herdr-synchronize-panes](https://github.com/furuhashin/herdr-synchronize-panes) | 1 | tmux synchronize-panes für den aktuellen Tab |
| [poweroutlet2/herdr-confirm-close-pane](https://github.com/poweroutlet2/herdr-confirm-close-pane) | 0 | Bestätigung vor dem Schließen eines Panes |
| [speardragon/herdr-yazi](https://github.com/speardragon/herdr-yazi) | 1 | Yazi in einem herdr-Pane öffnen (du nutzt yazi in tmux!) |
| [devskale/herdr-flist](https://github.com/devskale/herdr-flist) | 3 | Verzeichnis-Sidebar, die dem Fokus folgt |
| [alexjsp/herdr-scrollback-capture](https://github.com/alexjsp/herdr-scrollback-capture) | 1 | Scrollback des fokussierten Panes als HTML/Text speichern |
| [ppggff/herdr-plugin](https://github.com/ppggff/herdr-plugin) | 1 | macOS-Eingabequellen pro Pane stabil halten |
| [gw31415/herdr-amphetamine-macos](https://github.com/gw31415/herdr-amphetamine-macos) | 0 | Hält den Mac wach (Amphetamine), solange Agents arbeiten |
| [iikjl/herdr-spotify](https://github.com/iikjl/herdr-spotify) | 0 | Spotify-Now-Playing-Overlay mit Playback-Steuerung |
| [GranamyrBR/herdr-english-coach](https://github.com/GranamyrBR/herdr-english-coach) | 0 | Agent loggt Grammatik-/Jargon-Korrekturen in ein Live-Seiten-Pane |

## Tab- & Titel-Verwaltung

| Plugin | ⭐ | Was es tut |
|---|---|---|
| [rjyo/herdr-window-title-sync](https://github.com/rjyo/herdr-window-title-sync) | 6 | Terminal-Titel aus Workspace/Tab/Agent-Session syncen |
| [wyattjoh/herdr-plugin-renamer](https://github.com/wyattjoh/herdr-plugin-renamer) | 1 | Worktree-Branch + Workspace automatisch nach dem ersten Prompt benennen (Apple FoundationModels/Codex) |
| [Newt6611/herdr-tab-title](https://github.com/Newt6611/herdr-tab-title) | 0 | Tabs automatisch nummerieren/benennen ("1. Codex, 2. Terminal") |
| [lmilojevicc/herdr-tab-rename](https://github.com/lmilojevicc/herdr-tab-rename) | 0 | Tabs nach cwd-Namen benennen, manuelle Namen bleiben |
| [bcihanc/herdr-claude-session-title](https://github.com/bcihanc/herdr-claude-session-title) | 0 | Claude-Code-Session-Titel in die Pane-Metadaten spiegeln |
| [mikevalstar/herdr-machine-title](https://github.com/mikevalstar/herdr-machine-title) | 0 | Äußeren Terminal-Titel auf `herdr@<hostname> · <workspace>` pinnen |

## Orchestrierung & Multi-Agent

| Plugin | ⭐ | Was es tut |
|---|---|---|
| [madarco/agentbox](https://github.com/madarco/agentbox) (+ [Plugin](https://github.com/madarco/agentbox-herdr-plugin)) | 219 | Agents parallel in sandboxed VMs, lokal oder Cloud |
| [inxx/herdr-plan-code-review](https://github.com/inxx/herdr-plan-code-review) | 0 | Ein Klick: Opus plant, Sonnet codet, Claude+Codex reviewen — vier Panes |
| [ribbons-digital/pi-herd](https://github.com/ribbons-digital/pi-herd) | 1 | Sichtbare Pi-Session-Orchestrierung mit Panes + Worktrees |
| [carsonjones/herdr-agent-dashboard](https://github.com/carsonjones/herdr-agent-dashboard) | 0 | `prefix+a`: Live-Dashboard aller laufenden Agents |
| [Phoobobo/herdr-agent-config-manager](https://github.com/Phoobobo/herdr-agent-config-manager) | 0 | Agent-Skills, MCP, Plugins und Hooks zentral erkennen/verwalten |
| [simoncrypta/agentic-dev-setup](https://github.com/simoncrypta/agentic-dev-setup) | 1 | Teilbares herdr+worktrunk-Layout für agentische Workflows |
| [alon-z/herdr-devup](https://github.com/alon-z/herdr-devup) | 1 | Per-Projekt-Dev-Stacks aus `.herdr/dev.toml`, Tunnel-URL-Sync |
| [maayanyosef/herdr-aws-ssm](https://github.com/maayanyosef/herdr-aws-ssm) | 1 | EC2-Instanz picken, über AWS SSM verbinden (kein Bastion/Public IP) |
| [Phoobobo/herdr-traex-integration](https://github.com/Phoobobo/herdr-traex-integration) | 0 | TraeX-Agent-State via Lifecycle-Hooks |

## Außerhalb des Marketplace (aus awesome-herdr)

Nicht als `herdr-plugin` getaggt — Skills, Clients, Apps und Editor-Plugins:

| Projekt | Kategorie | Was es tut |
|---|---|---|
| ✅ [ogulcancelik/herdr SKILL.md](https://github.com/ogulcancelik/herdr/blob/master/SKILL.md) | Skill | Offizieller Skill: Agents steuern herdr selbst (Panes, Warten auf Agents) |
| [yigitkonur/herdr-pm](https://github.com/yigitkonur/herdr-pm) | Skill | Technischer PM pro Tab, der dirigiert statt codet |
| [msadig/herdr-peer-agents-skill](https://github.com/msadig/herdr-peer-agents-skill) | Skill | Agents spawnen benannte Peer-Agents und kollaborieren |
| [david-lutz/herdr-claude-teams](https://github.com/david-lutz/herdr-claude-teams) | Skill | Claude-Agent-Teams als native Panes |
| herdr-mcp / herdr-simple-mcp / herdr-mesh | MCP | herdr aus MCP-Clients steuern (simple-mcp: 75 Tools, stateless) |
| herdr-python-client / herdr-sock-go | API-Client | Python-/Go-Clients für die Socket-API |
| [herdr.nvim (devxplay)](https://github.com/devxplay/herdr.nvim) u. Varianten | Editor | NeoVim-Integrationen für Pane-Navigation (wir nutzen stattdessen vim-herdr-navigation) |
| [Daniel-Steinberger/obsidian-herdr](https://github.com/Daniel-Steinberger/obsidian-herdr) | Editor | Nächstes To-do aus Obsidian-Checkliste an den passenden Workspace-Agent senden |
| switchr / herdrctx | Session-TUI | Externe Session-Picker/-Manager |
| [herdr-menu-bar](https://github.com/search?q=herdr-menu-bar) | macOS | Agent-Status-Widget in der Menüleiste |
| herdr-ios / herdr-web / herdr-webui / kcosr/herdr-web | Remote | iOS-Client bzw. Browser-Viewer für Sessions |
| stream-deck-herdr-plugin / herdr-ulanzi-deck | Hardware | Agent-Status auf Stream Deck / Ulanzi-Keypad |
| gaijinjoe/herdres / alexei-led/ccgram | Messaging | Pane-Output bzw. Agent-Steuerung via Telegram |
| erwins-enkel/shepherd | Fleet | Web-/Phone-Mission-Control für Agent-Flotten |
| carze/herdr-smolmachine | Sandbox | Jedes Agent-Pane in einer microVM |
| vaclavik-xyz/herdwatch | CI | Pane bleibt "working", bis CI durch ist |
| native-shortcuts-herd | UX | macOS-native Keys in Ghostty + herdr |

## Meine Empfehlungs-Shortlist zum Nachrüsten

Nach Sichtung aller 113+: Diese würde ich mir als Nächstes anschauen, weil sie
zu deinem Stack (yazi, zoxide, worktrees, GitHub, macOS) passen:

1. **herdr-spreader** oder **herdr-sessionizer** — deklarative Workspace-Layouts pro Projekt (dein `sesh`-Äquivalent für herdr)
2. **herdr-reviewr** — Review-Sidebar für Agent-Änderungen, Kommentare gehen zurück an den Agent
3. **herdr-focus-notify** — klickbare macOS-Toasts statt In-App (Klick springt zum Pane)
4. **herdr-worktree-setup** — .env/direnv/deps automatisch in neuen Worktrees
5. **herdr-yazi** + **herdr-pluck** — yazi-Pane und Token-Kopieren wie tmux-fingers
6. **herdr-file-viewer** — meiste Sterne im UI-Bereich, Git-aware Diffs neben dem Agent
7. **herdr-resurrect** — Workspace-Snapshots über Reboots
