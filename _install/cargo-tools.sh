#!/usr/bin/env bash
#
# Install the cargo crates declared in _install/cargo-tools.list.
#
# The list only holds crates that Homebrew does NOT ship — everything available
# as a formula lives in brew/Brewfile.* so `brew bundle cleanup` can see it.
# Installs go through `cargo binstall` (prebuilt binary from the project's
# GitHub releases, no compile) and fall back to `cargo install` when no
# matching artifact exists.
#
# Usage:
#   cargo-tools.sh            install missing crates (no-op when all present)
#   cargo-tools.sh --update   additionally upgrade every unpinned crate
#
# NOTE: these are third-party crates compiled or downloaded from the internet.
# Review the list before running this on a new machine.

set -euo pipefail

MODE="install"
case "${1:-}" in
    --update) MODE="update" ;;
    "") ;;
    *)
        echo "  ERROR: unknown argument '$1' (expected --update or nothing)."
        exit 1
        ;;
esac

LIST="${CARGO_TOOLS_LIST:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/cargo-tools.list}"

if [[ ! -f "$LIST" ]]; then
    echo "  ERROR: manifest not found: $LIST"
    exit 1
fi

if ! command -v cargo &>/dev/null; then
    echo "  ERROR: cargo not found on PATH — install the toolchain first (bash _install/rust.sh)."
    exit 1
fi

# cargo-binstall is declared in brew/Brewfile.20-dev-tools; without it every
# crate compiles from source, which still works but is far slower.
if cargo binstall -V &>/dev/null; then
    HAVE_BINSTALL=1
else
    HAVE_BINSTALL=0
    echo "  ! cargo-binstall missing — falling back to source builds (brew bundle installs it)."
fi

# Snapshot what is currently installed: "name v1.2.3:" lines from cargo's own list.
INSTALLED="$(cargo install --list 2>/dev/null | grep -E '^[^ ].* v[0-9]' || true)"

installed_version() {
    # $1 = crate name → prints the installed version, or nothing when absent.
    echo "$INSTALLED" | sed -n "s/^$1 v\([^:]*\):.*/\1/p" | head -1
}

install_crate() {
    # $1 = crate name, $2 = pinned version (may be empty)
    local name="$1" version="$2"
    if [[ "$HAVE_BINSTALL" == "1" ]]; then
        if [[ -n "$version" ]]; then
            cargo binstall --no-confirm "${name}@${version}" && return 0
        else
            cargo binstall --no-confirm "$name" && return 0
        fi
        echo "    binstall found no prebuilt artifact — building from source"
    fi
    if [[ -n "$version" ]]; then
        cargo install --locked --version "$version" "$name"
    else
        cargo install --locked "$name"
    fi
}

changed=0
skipped=0

while IFS= read -r line; do
    # Strip comments and surrounding whitespace, skip blanks.
    entry="${line%%#*}"
    entry="$(echo "$entry" | tr -d '[:space:]')"
    [[ -z "$entry" ]] && continue

    name="${entry%%@*}"
    version=""
    [[ "$entry" == *"@"* ]] && version="${entry#*@}"

    current="$(installed_version "$name")"

    if [[ -z "$current" ]]; then
        echo "  → installing ${entry}"
        install_crate "$name" "$version"
        changed=$((changed + 1))
    elif [[ -n "$version" && "$current" != "$version" ]]; then
        echo "  → ${name}: pinned ${version}, installed ${current} — converging"
        install_crate "$name" "$version"
        changed=$((changed + 1))
    elif [[ -z "$version" && "$MODE" == "update" ]]; then
        echo "  → updating ${name} (currently ${current})"
        install_crate "$name" ""
        changed=$((changed + 1))
    else
        echo "  ○ ${name} ${current} already present"
        skipped=$((skipped + 1))
    fi
done < "$LIST"

echo "Done. ${changed} installed/updated, ${skipped} already current."
echo "Verify with: cargo install --list"
