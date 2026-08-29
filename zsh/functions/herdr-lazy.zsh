# ─────────────────────────────────────────────────────────────
# herdr-lazy - CLI wrapper for the herdr-lazy plugin manager
# ─────────────────────────────────────────────────────────────
# The binary lives inside herdr's plugin directory whose name contains an
# install-specific hash, so it cannot be symlinked onto PATH. This wrapper
# resolves the plugin root via herdr itself (recommended by upstream README).
# The declarative list is pointed into the dotfiles repo via HERDR_LAZY_LIST
# (see zsh/.zprofile).

herdr-lazy() {
  local root
  root=$(herdr plugin list --json | python3 -c \
    "import json,sys;print([p['plugin_root'] for p in json.load(sys.stdin)['result']['plugins'] if p['plugin_id']=='herdr-lazy'][0])") || {
    echo "herdr-lazy: plugin not installed (herdr plugin install natori-hrj/herdr-lazy)" >&2
    return 1
  }
  "$root/target/release/herdr-lazy" "$@"
}
