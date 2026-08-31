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

# Snapshot what is currently installed. A FAILING `cargo install --list` must not
# read as "nothing is installed" — that would silently reinstall every crate in
# the manifest over a corrupt or unreadable cargo state instead of reporting it.
if ! INSTALLED_RAW="$(cargo install --list 2>&1)"; then
    echo "  ERROR: \`cargo install --list\` failed — refusing to assume nothing is installed."
    printf '%s\n' "$INSTALLED_RAW" | sed 's/^/    /'
    exit 1
fi
INSTALLED="$(printf '%s\n' "$INSTALLED_RAW" | grep -E '^[^[:space:]].* v[0-9]' || true)"

installed_version() {
    # $1 = crate name → prints the installed version, or nothing when absent.
    # awk on whole fields rather than a regex with the name interpolated into it:
    # a locally-sourced crate prints `name v1.2.3 (/path):`, where a "everything
    # up to the first colon" capture would return the path along with the version.
    printf '%s\n' "$INSTALLED" | awk -v n="$1" '
        $1 == n && $2 ~ /^v[0-9]/ { v = substr($2, 2); sub(/:$/, "", v); print v; exit }'
}

install_crate() {
    # $1 = crate name, $2 = pinned version (may be empty).
    # Returns non-zero on failure; every caller runs it as an `if` condition so a
    # single unbuildable crate does not abort the rest of the manifest under -e.
    local name="$1" version="$2" spec="$1"
    [[ -n "$version" ]] && spec="${name}@${version}"
    if [[ "$HAVE_BINSTALL" == "1" ]]; then
        if cargo binstall --no-confirm "$spec"; then
            return 0
        fi
        # Deliberately vague: binstall exits non-zero for a missing artifact and
        # for network, checksum and argument errors alike, and it does not
        # distinguish them in its status. Claiming "no prebuilt artifact" here
        # would misreport the other three.
        echo "    binstall did not succeed — falling back to a source build"
    fi
    if [[ -n "$version" ]]; then
        cargo install --locked --version "$version" "$name"
    else
        cargo install --locked "$name"
    fi
}

changed=0
skipped=0
failed=0

# `|| [[ -n "$line" ]]` so a manifest whose last line lacks a trailing newline
# still yields that crate instead of dropping it.
while IFS= read -r line || [[ -n "$line" ]]; do
    entry="${line%%#*}"
    # Trim leading and trailing whitespace ONLY. Deleting all whitespace would
    # turn a typo like `foo bar` into the single crate `foobar` and install it.
    entry="${entry#"${entry%%[![:space:]]*}"}"
    entry="${entry%"${entry##*[![:space:]]}"}"
    [[ -z "$entry" ]] && continue

    case "$entry" in
        *[[:space:]]*)
            echo "  ERROR: malformed entry '${entry}' in ${LIST} (embedded whitespace)."
            exit 1
            ;;
        *@*@*)
            echo "  ERROR: malformed entry '${entry}' in ${LIST} (more than one '@')."
            exit 1
            ;;
    esac

    name="${entry%%@*}"
    version=""
    [[ "$entry" == *"@"* ]] && version="${entry#*@}"
    if [[ -z "$name" ]] || { [[ "$entry" == *"@"* ]] && [[ -z "$version" ]]; }; then
        echo "  ERROR: malformed entry '${entry}' in ${LIST} (empty crate name or version)."
        exit 1
    fi

    current="$(installed_version "$name")"
    action=""

    if [[ -z "$current" ]]; then
        echo "  → installing ${entry}"
        action="install"
    elif [[ -n "$version" && "$current" != "$version" ]]; then
        echo "  → ${name}: pinned ${version}, installed ${current} — converging"
        action="install"
    elif [[ -z "$version" && "$MODE" == "update" ]]; then
        echo "  → updating ${name} (currently ${current})"
        action="install"
    else
        echo "  ○ ${name} ${current} already present"
        skipped=$((skipped + 1))
    fi

    if [[ "$action" == "install" ]]; then
        if install_crate "$name" "$version"; then
            changed=$((changed + 1))
        else
            echo "  ✗ ${entry} failed — continuing with the rest of the manifest"
            failed=$((failed + 1))
        fi
    fi
done < "$LIST"

echo "Done. ${changed} installed/updated, ${skipped} already current, ${failed} failed."
echo "Verify with: cargo install --list"
[[ "$failed" -eq 0 ]] || exit 1
