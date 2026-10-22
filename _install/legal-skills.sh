#!/usr/bin/env bash
#
# Install a curated set of German-law skills from
# Klotzkette/claude-fuer-deutsches-recht for every local coding agent.
#
# Why not `npx skills add Klotzkette/claude-fuer-deutsches-recht` directly:
#   - The repo ships ~23k skills (2.4 GB); installing all of them floods every
#     agent's skill listing and buries the skills we actually use.
#   - Names collide across plugins (e.g. `juristischer-argumentationskern`
#     exists 230 times), so `--skill <name>` cannot pick the right variant.
#   - Most skills link `../../references/*.md` (plugin-level files). `npx skills`
#     copies only the skill folder, which would break those links.
#
# So we sparse-clone only the selected skills, vendor each plugin's
# references/scripts/templates into every skill folder, rewrite the links,
# and install the result as a local package via `npx skills`.
#
# Layout after install (managed by `npx skills`):
#   ~/.agents/skills/<skill>               (copied, self-contained)
#   ~/.claude/skills/<skill> etc.          -> symlinks into ~/.agents/skills
#
# Usage: legal-skills.sh   (idempotent — re-run to update to upstream HEAD)
# Remove: npx skills remove -g -y -s <skill> ...

set -euo pipefail

REPO="https://github.com/Klotzkette/claude-fuer-deutsches-recht.git"
AGENTS=(claude-code codex cursor pi)

# <plugin>/<skill> — keep this list small; every entry costs listing context.
SKILLS=(
    # Contracts: B2B contract from order to signed version
    vertragserstellung/daten-nutzungsrechte-und-geheimhaltung-regeln
    vertragserstellung/eckpunkte-form-und-vertretung-festlegen
    vertragserstellung/haftung-und-maengelrechte-abstimmen
    vertragserstellung/laufzeit-und-vertragsende-regeln
    vertragserstellung/leistung-mitwirkung-und-abnahme-ausformulieren
    vertragserstellung/nachtrag-mit-folgeaenderungen-erstellen
    vertragserstellung/preis-zahlung-und-sicherung-vereinbaren
    vertragserstellung/verhandlung-und-unterschriftenfassung-abschliessen
    vertragserstellung/vertrag-vom-auftrag-bis-zur-endfassung-erstellen
    vertragserstellung/vertragsrangfolge-und-agb-bereinigen
    # Terms and conditions (AGB) for services and web shops
    agb-werkstatt/agb-auftrag-klaeren
    agb-werkstatt/agb-endfassung-einfuehren
    agb-werkstatt/agb-haftung-maengel
    agb-werkstatt/agb-hauptproblem-loesen
    agb-werkstatt/agb-preise-laufzeit-aenderung
    agb-werkstatt/agb-rechtsprechung-abgleichen
    agb-werkstatt/agb-webshop-checkout
    # GDPR: record of processing (basis for privacy notices, Art. 13/14)
    verarbeitungsverzeichnis/aenderungen-nachhalten
    verarbeitungsverzeichnis/dienstleister-transfers-tom-pruefen
    verarbeitungsverzeichnis/rechtsgrundlagen-loeschung-pruefen
    verarbeitungsverzeichnis/risiken-dsfa-pruefen
    verarbeitungsverzeichnis/verarbeitungen-erheben
    verarbeitungsverzeichnis/verarbeitungsverzeichnis-steuern
    verarbeitungsverzeichnis/verzeichnis-ausgeben
    verarbeitungsverzeichnis/verzeichnis-erstellen
    # GDPR: processor agreements, third-country transfers, supervisory authority
    datenschutzrecht/avv-pruefung
    datenschutzrecht/avv-art-28-mindestinhalte-checkliste
    datenschutzrecht/avv-tom-art-32-dsgvo-anlage
    datenschutzrecht/drittlandstransfer-pruefung
    datenschutzrecht/sanktion-behoerdenkommunikation
    # Quality lift: source verification and legal reasoning chain
    ki-halluzinationsreduzierer/amtliche-quellen-erschliessen
    ki-halluzinationsreduzierer/aussagen-am-volltext-pruefen
    ki-halluzinationsreduzierer/entscheidungsidentitaet-abgleichen
    ki-halluzinationsreduzierer/fundstellen-inventarisieren
    ki-halluzinationsreduzierer/halluzinationspruefung-steuern
    ki-halluzinationsreduzierer/literatur-materialien-und-standards-pruefen
    ki-halluzinationsreduzierer/nachpruefung-und-qualitaetskontrolle
    ki-halluzinationsreduzierer/normfassungen-und-zeitbezug-pruefen
    ki-halluzinationsreduzierer/pruefbericht-und-korrekturfassung-erstellen
    ki-halluzinationsreduzierer/uebertragbarkeit-und-gegenargumente-pruefen
    ki-halluzinationsreduzierer/zitate-und-randnummern-pruefen
    subsumtions-pruefer/juristischer-argumentationskern
)

# Plugin-level folders that skills link to via ../../<dir>/
VENDORED_DIRS=(references scripts templates)

if ! command -v npx &>/dev/null; then
    echo "  ERROR: npx not found on PATH — install Node.js first."
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
SRC="$WORK/src"
BUNDLE="$WORK/bundle"
mkdir -p "$BUNDLE"

# Sparse, blobless clone: fetch only the selected skills plus plugin assets.
patterns=()
for entry in "${SKILLS[@]}"; do
    plugin="${entry%%/*}"
    patterns+=("/$plugin/skills/${entry#*/}/")
    for dir in "${VENDORED_DIRS[@]}"; do
        patterns+=("/$plugin/$dir/")
    done
done
git clone --quiet --depth 1 --filter=blob:none --no-checkout "$REPO" "$SRC"
git -C "$SRC" sparse-checkout set --no-cone "${patterns[@]}"
git -C "$SRC" checkout --quiet
echo "  fetched $(git -C "$SRC" rev-parse --short HEAD) from $REPO"

for entry in "${SKILLS[@]}"; do
    plugin="${entry%%/*}"
    skill="${entry#*/}"
    from="$SRC/$plugin/skills/$skill"
    if [[ ! -f "$from/SKILL.md" ]]; then
        echo "  ERROR: $entry not found upstream — update SKILLS in $0"
        exit 1
    fi
    cp -R "$from" "$BUNDLE/$skill"
    for dir in "${VENDORED_DIRS[@]}"; do
        if [[ -d "$SRC/$plugin/$dir" ]]; then
            cp -R "$SRC/$plugin/$dir" "$BUNDLE/$skill/$dir"
        fi
    done
    # ../../references/x.md -> references/x.md (same for scripts/templates)
    find "$BUNDLE/$skill" -name '*.md' -exec \
        sed -i '' -E 's#\.\./\.\./(references|scripts|templates)/#\1/#g' {} +
done

# Report links to skills that are not part of this selection.
dangling=$(grep -rhoE '\]\(\.\./[^/)]+/SKILL\.md' "$BUNDLE"/*/SKILL.md \
    | sed -E 's#.*\.\./([^/]+)/SKILL\.md#\1#' | sort -u \
    | while read -r target; do [[ -d "$BUNDLE/$target" ]] || echo "$target"; done)
if [[ -n "$dangling" ]]; then
    echo "  note: links to skills not installed: ${dangling//$'\n'/ }"
fi

npx -y skills@latest add "$BUNDLE" --global --yes --skill '*' --agent "${AGENTS[@]}"

echo "Done. ${#SKILLS[@]} German-law skills installed for: ${AGENTS[*]}"
