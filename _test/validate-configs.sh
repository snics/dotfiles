#!/usr/bin/env bash
# Validate JSON and TOML config file syntax
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
errors=0

echo "==> Checking JSON files..."
# Skip directories known to use JSONC (JSON with comments)
JSONC_DIRS="zed/.config/zed|cursor/Library"
while IFS= read -r f; do
  if echo "$f" | grep -qE "$JSONC_DIRS"; then
    echo "  SKIP (JSONC): $f"
    continue
  fi
  if ! python3 -m json.tool "$f" > /dev/null 2>&1; then
    echo "  FAIL: $f"
    errors=$((errors + 1))
  else
    echo "  OK: $f"
  fi
done < <(find "$DOTFILES" -name '*.json' -not -path '*/.git/*' -not -path '*/node_modules/*')

echo ""
echo "==> Checking TOML files..."
while IFS= read -r f; do
  if python3 -c "import tomllib; tomllib.load(open('$f','rb'))" 2>/dev/null \
     || python3 -c "import tomli; tomli.load(open('$f','rb'))" 2>/dev/null; then
    echo "  OK: $f"
  else
    echo "  FAIL: $f"
    errors=$((errors + 1))
  fi
done < <(find "$DOTFILES" -name '*.toml' -not -path '*/.git/*')

echo ""
if [ "$errors" -gt 0 ]; then
  echo "$errors config file(s) invalid."
  exit 1
fi
echo "All config files valid."
