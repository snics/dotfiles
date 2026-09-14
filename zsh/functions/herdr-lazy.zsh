# ─────────────────────────────────────────────────────────────
# herdr-lazy - CLI wrapper for the herdr-lazy plugin manager
# ─────────────────────────────────────────────────────────────
# The binary lives inside herdr's plugin directory whose name contains an
# install-specific hash, so it cannot be symlinked onto PATH. This wrapper
# resolves the plugin root via herdr itself (recommended by upstream README).
# The declarative list is pointed into the dotfiles repo via HERDR_LAZY_LIST
# (see zsh/.zprofile).

herdr-lazy() {
  local json root
  # Capture stderr too: herdr reports errors (e.g. protocol_mismatch after a
  # CLI upgrade while the old server still runs) as JSON on the error stream.
  if ! json=$(herdr plugin list --json 2>&1); then
    echo "herdr-lazy: 'herdr plugin list' failed:" >&2
    echo "$json" >&2
    return 1
  fi
  root=$(print -r -- "$json" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except ValueError:
    sys.stderr.write("unexpected non-JSON response\n")
    sys.exit(2)
if "error" in data:
    sys.stderr.write(data["error"].get("message", "unknown herdr error") + "\n")
    sys.exit(2)
roots = [p["plugin_root"] for p in data["result"]["plugins"] if p["plugin_id"] == "herdr-lazy"]
if not roots:
    sys.exit(3)
print(roots[0])
')
  case $? in
    2) echo "herdr-lazy: herdr reported an error (see above)" >&2; return 1 ;;
    3) echo "herdr-lazy: plugin not installed (herdr plugin install natori-hrj/herdr-lazy)" >&2; return 1 ;;
  esac
  "$root/target/release/herdr-lazy" "$@"
}
