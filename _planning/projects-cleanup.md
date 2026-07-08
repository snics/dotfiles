# ~/Projects — Aufräumplan (final konsolidiert)

Stand: 2026-07-08, nach drei Subagent-Scans (Kategorien, Fremd-Klone,
Voll-gepusht-Analyse Clients/Startups).

## ✅ AUSGEFÜHRT am 2026-07-08 (per `trash` — 30 Tage im Papierkorb)

Startuts/, Learning/, Throwaway/ (inkl. expoTest), Non-Profit/, Scripts/,
Tools/ (inkl. diabetes-tagebuch-generator + netbootxyz), GFU-Escape-Duplikat,
GitHub: bitnami-chart, payload, meala-app, panache, docker_parser,
k8s-for-devs (0 unpushed commits verifiziert), AI Agents Library,
Loop Widget Playground. **~10 GB freigegeben.**
Explizit BEHALTEN laut Nico: local-nightscout, Workshop/CKA,
kubernetes-cluster-workshop, cal.com.

## ✅ ARCHIVIERT am 2026-07-08 → `~/Projects/_archive/` (25 GB, nur verschoben)

- Clients: RheinNetz GmbH, Impect GmbH, workshops.de, ifok.digital-platform
  (alter Flach-Checkout)
- Startups: DataMedis GmbH (komplett), Avoplan/DevOps/helm-charts,
  DevNinjas/{calcom-infrastructure, infrastructure, DevNinjas.io (alt),
  dev-workspaces}
- GitHub: my-project, LoopKit-LoopWorkspace, LoopPowerPack,
  keycloakify-starter, keycloakify-shadcn-starter, TinderBotz
- GitLab (komplett)

Nicht verschoben: GFU calculate-/mesh-service (liegen mitten im
Schulungsmaterial "Microservices mit Docker und Kubernetes" — gehören dort
hin); gsuite-signature-manager (außerhalb des Archivs nicht mehr auffindbar,
vermutlich in einem verschobenen Baum).

**Nico-Entscheidung:** `GitHub/k8s-outlet` bleibt wie es ist (kein Remote,
119 ungepushte Commits — bewusst akzeptiertes Backup-Risiko).
Offen nur noch: ifok-Token-Fix, K8s-Layout-Overrides
(dn-k8s-infrastructure, ifok).

## 🚨 Handlungsbedarf ZUERST (nicht löschen — sichern!)

| Repo | Problem | Aktion |
|---|---|---|
| `GitHub/k8s-outlet` (9,2 GB) | Kein Remote, **119 ungepushte Commits** | GitHub-Repo anlegen + pushen |
| `Clients/RheinNetz GmbH/k8s-test-cluster` | **Kein Remote** — aktive Kundenarbeit (Mai 2026)! | Remote anlegen + pushen |
| `Startups/DevNinjas/calcom-infrastructure` (1,6 GB) | Kein Remote, dirty=5 | Remote anlegen |
| `Startups/DevNinjas/infrastructure` (1,9 GB) | Kein Remote, dirty=10 | Remote anlegen |
| `Startups/DevNinjas/DevNinjas.io` (alt, 6,6 GB) | **74.776 dirty Files + 9 Stashes** | Sichten → vermutlich Archiv (alte Website) |
| `GitHub/k8s-for-devs` | 257 uncommittete Änderungen | committen/pushen |
| `Workshop/CKA` | 252 uncommittete Änderungen | committen/pushen (vor Umzug nach Talks!) |
| `GitHub/kubernetes-cluster-workshop` | 5 ungepushte Commits | pushen |
| `Clients/ifok/ifok.digital-platform` | **Token in Remote-URL** | URL auf SSH/Credential-Helper umstellen |
| `GitHub/my-project` (963 MB) | Lokal-only, 203 Änderungen — **unbekannt, Nico fragen** | identifizieren |

## ✅ A — Sofort löschbar (kein Datenverlust möglich)

| Was | Umfang |
|---|---|
| `Startuts/`, `Clients/GFU\ Cyrus\ AG/` (Escape-Leer-Duplikat), `Learning/` | Müll/leer |
| Fremd-Klone unverändert: `GitHub/bitnami-chart`, `GitHub/payload`, `GitHub/meala-app`, `GitHub/panache` | 4,0 GB |
| `Clients/ifok.digital-platform/` (flacher Alt-Checkout — laut Scan voll gepusht) | 143 MB |
| Voll gepusht & inaktiv (15 Repos: DataMedis automation/base/case/export/list/eslint/oracle/www, Impect impect.com+packing, Avoplan helm-charts, cloudnative-workshop, dev-workspaces, docker-k8s-training-image-Duplikat u. a.) | 2,8 GB |
| `Non-Profit/` ("Fight for Flight", <1 MB — Nico: kann weg) | klein |
| `Throwaway/` **außer** `expoTest` (peppermint, testFlutterApp, getwidget×2) | ~1,6 GB |

**Summe A: ~8,5 GB**

## 🟡 B — Kurz sichten, dann löschbar (~5,2 GB)

Fremd-Klone mit 1–4 lokal geänderten Dateien: `cal.com` (1,4 GB),
`LoopKit-LoopWorkspace` (802 MB), `LoopPowerPack` (744 MB),
`keycloakify-starter` (348 MB), `gsuite-signature-manager`, `TinderBotz`,
`GitHub/keycloakify-shadcn-starter` (557 MB — DevNinjas-Kopie ist voll
gepusht & aktiv → vermutlich die Arbeitskopie, GitHub-Kopie weg).

## ❓ Offene Nico-Entscheidungen

1. `Throwaway/expoTest` (594 MB, kein Remote, 57 Änderungen) — endgültig weg?
2. `GitHub/my-project` (963 MB, lokal-only) — was ist das?
3. `Clients/GFU Cyrus AG/{calculate,mesh}-service` — lokal-only, aber ohne
   Commits (leere Init-Repos?) → vermutlich weg
4. DataMedis: 15 weitere Repos "LOKALE ARBEIT" (Stashes/dirty, alle 2020–22,
   ~4 GB) — Firma noch relevant? → Wholesale-Archiv statt Einzel-Push?
5. Hafeneger Motorsport (4 Repos, ~3 GB, Stashes, 2021–23) → Archiv?

## 📦 C — Archivieren → `~/Projects/_archive/`

`Tools/diabetes-tagebuch-generator` (eigene App ohne Git!), `Scripts/dgma`
(WordPress 2020), `GitLab/`, ggf. DataMedis + Hafeneger (siehe oben).
`Tools/netbootxyz` → löschen (Compose-Setup, reproduzierbar).

## 🔀 D — Umbau

- `Workshop/` → `Talks/` (erst CKA committen!)
- sessionizer-Roots danach nachziehen (Workshop raus)
- `.sessionizer/config.toml`-K8s-Overrides: dn-k8s-infrastructure,
  RheinNetz k8s-test-cluster, ifok — nach den Remote-Fixes

## Zieleffekt

~14 GB frei (A+B), alle ⚠️-Repos gesichert statt gefährdet, Picker zeigt
nur aktive Arbeit, einheitliche Struktur `Kategorie/<Org|Kunde>/<Repo>`.
