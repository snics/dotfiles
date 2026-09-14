# ─────────────────────────────────────────────────────────────
# update - Unified update command for the entire system
# ─────────────────────────────────────────────────────────────
#
# TODO: Evaluate ZeroBrew (https://github.com/lucasgelfond/zerobrew)
#   Rust-based Homebrew alternative with 2-20x speedup (benchmarked).
#   Currently only supports formulae — no cask or brew bundle support.
#   Once cask + bundle support lands, consider replacing the _update_brew()
#   Homebrew calls with ZeroBrew equivalents (zb install, zb bundle, zbx).
#   Track progress: https://github.com/lucasgelfond/zerobrew/issues
#
# TODO: Auto-flash ZSA keyboards on `update` when connected.
#   Add an `_update_keyboards()` target that detects a ZSA keyboard via USB
#   (vendor ID 0x3297 — Voyager / Moonlander / Ergodox EZ / Halfmoon / Planck EZ)
#   using `system_profiler SPUSBDataType -json` and, if found, runs `zapp update`
#   to fetch the latest Oryx layout revision and flash it automatically.
#   Notes:
#     - `zapp` is now installed via brew/Brewfile.80-misc.
#     - `zapp update` only works when the keyboard runs Oryx-built firmware
#       AND is NOT in bootloader mode — should prompt the user to reset
#       the keyboard once detected, then continue.
#     - Skip target silently if no ZSA device is connected (no _update_not_found
#       noise — keyboards are an optional, hardware-dependent target).
#   Track upstream: https://github.com/zsa/zapp
#
# Usage:
#   update              Interactive mode (prompts per target)
#   update -y           Update everything without prompting
#   update brew         Only update Homebrew
#   update brew zsh     Update Homebrew and Zsh
#   update -y -d        Update everything + rebuild dock
#   update -y -r        Update everything + restart herdr server if outdated
#   update help         Show help with available targets
#

# ── Privileges ──────────────────────────────────────────────
# No password caching here: only the `system` target needs sudo, and
# /etc/pam.d/sudo_local makes every sudo prompt a Touch ID tap (pam_tid,
# with pam_reattach for tmux/herdr sessions). Casks that need elevated
# rights prompt on their own the same way.

# ── UI Helpers ──────────────────────────────────────────────

typeset -ga _update_results=()

_update_header() {
  local emoji="$1" name="$2"
  echo ""
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo "\033[1;37m ${emoji}  ${name}\033[0m"
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

_update_success() {
  echo " \033[1;32m✓\033[0m  $1 done"
  _update_results+=("\033[1;32m ✓\033[0m  $1")
}

_update_fail() {
  echo " \033[1;31m✗\033[0m  $1"
  _update_results+=("\033[1;31m ✗\033[0m  $1")
}

_update_skip() {
  echo ""
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo "\033[1;33m ⏭  $1 (skipped)\033[0m"
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  _update_results+=("\033[1;33m ⏭\033[0m  $1 (skipped)")
}

_update_not_found() {
  echo ""
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo "\033[1;90m ○  $1 (not installed)\033[0m"
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  _update_results+=("\033[1;90m ○\033[0m  $1 (not installed)")
}

_update_ask() {
  local name="$1"
  [[ "$_update_all" == true ]] && return 0
  echo -n " ${name}: Update? [y/N] "
  read -r answer
  [[ "$answer" =~ ^[Yy] ]]
}

_update_summary() {
  echo ""
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo "\033[1;37m 📋  Summary\033[0m"
  echo "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  for r in "${_update_results[@]}"; do
    echo "$r"
  done
  echo ""
}

# ── Update Targets ──────────────────────────────────────────

_update_system() {
  _update_header "🖥️" "System"
  echo "Running macOS Software Update..."
  sudo softwareupdate -i -a
  _update_success "System"
}

_update_brew() {
  if ! command -v brew &>/dev/null; then
    _update_not_found "Homebrew"
    return
  fi
  _update_header "🍺" "Homebrew"
  echo "Updating Homebrew..."
  local -a _brew_failed=()
  brew update || _brew_failed+=("brew update exit $?")
  echo "Regenerating Brewfile..."
  cat "$HOME/.dotfiles/brew"/Brewfile.* >| "${HOMEBREW_BUNDLE_FILE:-$HOME/.Brewfile}"
  echo "Upgrading from Brewfile..."
  # Since Homebrew 6.0 `brew bundle` batches every formula and cask into a
  # single `brew install`. A single bad entry (tap conflict, keg-only clash)
  # aborts that batch in pre-flight, and bundle then reports *every* still
  # outdated entry as "Upgrading <x> has failed!" — dozens of red lines for
  # one root cause, with the real error buried in the batch output. Keep the
  # exit code so the summary stops claiming success.
  brew bundle || _brew_failed+=("brew bundle exit $?")
  # `brew bundle` only upgrades formulae declared in the Brewfile. Transitive
  # dependencies (openssl, python@x, …) are not declared, so without this step
  # they stay outdated forever — including security-relevant libraries.
  echo "Upgrading remaining formulae (dependencies)..."
  brew upgrade --formula || _brew_failed+=("brew upgrade exit $?")
  # --greedy-auto-updates covers self-updating apps but skips `version :latest`
  # casks (fonts etc.), which plain --greedy re-downloads on every single run.
  echo "Upgrading Cask apps (auto-updating ones included)..."
  brew upgrade --cask --greedy-auto-updates || _brew_failed+=("brew upgrade --cask exit $?")
  echo "Cleaning up..."
  brew cleanup || _brew_failed+=("brew cleanup exit $?")
  if (( ${#_brew_failed} )); then
    _update_fail "Homebrew (${(j:, :)_brew_failed})"
    echo "    Re-run 'brew bundle --verbose' to see the error that aborted the batch."
  else
    _update_success "Homebrew"
  fi
}

_update_mas() {
  if ! command -v mas &>/dev/null; then
    _update_not_found "Mac App Store"
    return
  fi
  _update_header "🍎" "Mac App Store"
  echo "Upgrading Mac App Store apps..."
  mas upgrade
  _update_success "Mac App Store"
}

_update_asdf() {
  if ! command -v asdf &>/dev/null; then
    _update_not_found "asdf"
    return
  fi
  _update_header "🔌" "asdf"
  echo "Updating all asdf plugins..."
  asdf plugin update --all
  _update_success "asdf"
}

_update_rust() {
  if ! command -v rustup &>/dev/null; then
    _update_not_found "Rust"
    return
  fi
  _update_header "🦀" "Rust"
  echo "Updating Rust toolchain..."
  rustup update
  # Crates without a Homebrew formula (declared in _install/cargo-tools.list);
  # the ones that do have a formula are covered by the brew target.
  local cargo_tools="$HOME/.dotfiles/_install/cargo-tools.sh"
  if [[ -x "$cargo_tools" ]]; then
    echo "Updating cargo tools (cargo-tools.list)..."
    bash "$cargo_tools" --update
  fi
  _update_success "Rust"
}

_update_nvim() {
  if ! command -v nvim &>/dev/null; then
    _update_not_found "Neovim"
    return
  fi
  _update_header "📝" "Neovim Plugins"
  echo "Syncing lazy.nvim plugins..."
  nvim --headless "+Lazy! sync" +qa
  _update_success "Neovim Plugins"
}

_update_krew() {
  if ! command -v kubectl &>/dev/null || ! kubectl krew version &>/dev/null 2>&1; then
    _update_not_found "Krew"
    return
  fi
  _update_header "☸️" "Krew"
  echo "Updating krew index..."
  kubectl krew update
  echo "Upgrading krew plugins..."
  kubectl krew upgrade
  _update_success "Krew"
}

_update_herdr() {
  if ! command -v herdr &>/dev/null; then
    _update_not_found "herdr Plugins"
    return
  fi
  _update_header "🐑" "herdr Plugins"
  local -a _herdr_failed=()
  echo "Syncing plugin bundle (plugins.list)..."
  herdr-lazy sync --prune || _herdr_failed+=("sync exit $?")
  echo "Updating all unpinned plugins..."
  herdr-lazy update || _herdr_failed+=("update exit $?")
  echo "Reloading herdr server config..."
  herdr server reload-config &>/dev/null || true
  if (( ${#_herdr_failed} )); then
    _update_fail "herdr Plugins (${(j:, :)_herdr_failed})"
  else
    echo "Note: updated plugins with running services need a herdr restart to pick them up."
    _update_success "herdr Plugins"
  fi
}

_update_skills() {
  if ! command -v npx &>/dev/null; then
    _update_not_found "Agent Skills"
    return
  fi
  _update_header "🧩" "Agent Skills"
  echo "Updating installed agent skills (skills.sh CLI)..."
  # -g pins the scope to global: `update` runs from whatever directory the
  # shell happens to be in, and the project scope would otherwise be picked
  # up from that cwd. -y skips the remaining deletion prompt, so the target
  # stays non-interactive; upstream-deleted skills are reported, never removed.
  npx -y skills update -g -y
  _update_success "Agent Skills"
}

_update_zsh() {
  _update_header "🐚" "Zsh/Zim"
  echo "Updating Zim modules..."
  zimfw update
  echo "Upgrading Zim framework..."
  zimfw upgrade
  _update_success "Zsh/Zim"
}

# ── herdr Server Check ──────────────────────────────────────
# After upgrades the herdr CLI can be newer than the still-running server
# (protocol mismatch: plugin/agent commands fail until a restart). Restarting
# kills every pane process — running Claude/Codex sessions included — and
# herdr's live handoff is disabled for package-manager (brew) installs.
# So this only warns or asks; it never restarts the server on its own.
_update_herdr_server_check() {
  command -v herdr &>/dev/null || return 0
  local st
  st=$(herdr status server --json 2>/dev/null) || return 0
  [[ "$st" == *'"restart_needed":true'* ]] || return 0

  echo ""
  echo "\033[1;33m ⚠  herdr: CLI was updated but the old server is still running\033[0m"
  echo "    (protocol mismatch — plugin/agent commands fail until a restart)."
  if [[ "${_restart_herdr:-false}" == true ]]; then
    if [[ "${HERDR_ENV:-}" == 1 ]]; then
      echo "    --restart-herdr: stopping the server now — this pane closes with it."
      echo "    Start herdr again afterwards; resume agents via 'claude --resume'"
      echo "    or 'codex resume'."
    else
      echo "    --restart-herdr: stopping the server (all pane processes exit)."
    fi
    herdr server stop && echo "    Server stopped — the next 'herdr' launch starts the new version."
    return 0
  fi
  if [[ "${HERDR_ENV:-}" == 1 ]]; then
    echo "    This shell runs inside herdr, so update can't restart it (that would"
    echo "    kill this very pane). When your sessions are done, run from a plain"
    echo "    terminal:  herdr server stop   — then start herdr again."
    echo "    Note: stopping exits ALL pane processes; agent sessions can be"
    echo "    resumed afterwards (claude --resume / codex resume)."
    return 0
  fi
  local answer
  echo -n "    Restart herdr server now? This exits ALL pane processes [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy] ]]; then
    herdr server stop && echo "    Server stopped — the next 'herdr' launch starts the new version."
  else
    echo "    Skipped. Restart later with: herdr server stop"
  fi
}

# ── Dispatch ────────────────────────────────────────────────

_update_run() {
  case "$1" in
    system) _update_system ;;
    brew)   _update_brew ;;
    mas)    _update_mas ;;
    asdf)   _update_asdf ;;
    rust)   _update_rust ;;
    nvim)   _update_nvim ;;
    herdr)  _update_herdr ;;
    skills) _update_skills ;;
    krew)   _update_krew ;;
    zsh)    _update_zsh ;;
    *)      echo "Unknown target: $1. Run 'update help' for available targets." ;;
  esac
}

# ── Target Registry ─────────────────────────────────────────

typeset -ga _UPDATE_TARGETS=()
# macOS-only: system updates (softwareupdate)
[[ "$(uname -s)" == "Darwin" ]] && _UPDATE_TARGETS+=("system:🖥️:System")
_UPDATE_TARGETS+=(
  "brew:🍺:Homebrew"
)
# macOS-only: Mac App Store (mas)
[[ "$(uname -s)" == "Darwin" ]] && _UPDATE_TARGETS+=("mas:🍎:Mac App Store")
_UPDATE_TARGETS+=(
  "asdf:🔌:asdf"
  "rust:🦀:Rust"
  "nvim:📝:Neovim Plugins"
  "herdr:🐑:herdr Plugins"
  "skills:🧩:Agent Skills"
  "krew:☸️:Krew"
  "zsh:🐚:Zsh/Zim"
)

# ── Help ────────────────────────────────────────────────────

_update_help() {
  echo ""
  echo "\033[1;37mUsage:\033[0m update [options] [targets...]"
  echo ""
  echo "\033[1;37mOptions:\033[0m"
  echo "  -y, --all            Update all without prompting"
  echo "  -d, --dock           Rebuild dock after updates"
  echo "  -r, --restart-herdr  Restart the herdr server at the end if it is"
  echo "                       outdated (exits all pane processes!)"
  echo "  help                 Show this help message"
  echo ""
  echo "\033[1;37mTargets:\033[0m"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "  system       macOS Software Update"
  fi
  echo "  brew         Homebrew (formulae + casks from Brewfile)"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "  mas          Mac App Store apps"
  fi
  echo "  asdf         asdf version manager plugins"
  echo "  rust         Rust toolchain (rustup) + cargo tools (cargo-tools.list)"
  echo "  nvim         Neovim plugins (lazy.nvim)"
  echo "  herdr        herdr plugins (herdr-lazy bundle)"
  echo "  skills       Agent skills for Claude/Codex (skills.sh CLI)"
  echo "  krew         kubectl plugins (krew)"
  echo "  zsh          Zsh/Zim framework + plugins"
  echo ""
  echo "\033[1;37mExamples:\033[0m"
  echo "  update            Interactive mode (prompts per target)"
  echo "  update -y         Update everything"
  echo "  update brew       Only update Homebrew"
  echo "  update brew zsh   Update Homebrew and Zsh"
  echo "  update -y -d      Update everything + rebuild dock"
  echo ""
  echo "\033[1;37mInstalled tools:\033[0m"
  command -v brew &>/dev/null   && echo "  brew         $(brew --version 2>/dev/null | head -1)"
  command -v mas &>/dev/null    && echo "  mas          $(mas version 2>/dev/null)"
  command -v asdf &>/dev/null   && echo "  asdf         $(asdf version 2>/dev/null)"
  command -v rustup &>/dev/null && echo "  rustup       $(rustup --version 2>/dev/null | head -1)"
  command -v nvim &>/dev/null   && echo "  nvim         $(nvim --version 2>/dev/null | head -1)"
  command -v herdr &>/dev/null  && echo "  herdr        $(herdr --version 2>/dev/null | head -1)"
  command -v npx &>/dev/null    && echo "  skills       $(npx -y skills --version 2>/dev/null | head -1)"
  command -v kubectl &>/dev/null && echo "  kubectl      $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"
  command -v zimfw &>/dev/null  && echo "  zimfw        $(zimfw version 2>/dev/null)"
  echo ""
}

# ── Main Function ───────────────────────────────────────────

update() {
  local _update_all=false
  local _dock=false
  local _restart_herdr=false
  local -a _targets=()
  _update_results=()

  # Parse arguments
  for arg in "$@"; do
    case $arg in
      -y|--all)           _update_all=true ;;
      -d|--dock)          _dock=true ;;
      -r|--restart-herdr) _restart_herdr=true ;;
      help)               _update_help; return 0 ;;
      *)                  _targets+=("$arg") ;;
    esac
  done

  if (( ${#_targets} > 0 )); then
    # Direct targets: run without prompting
    for t in "${_targets[@]}"; do
      _update_run "$t"
    done
  else
    # Interactive mode: prompt per target (or run all with -y)
    for entry in "${_UPDATE_TARGETS[@]}"; do
      local key="${entry%%:*}"
      local rest="${entry#*:}"
      local emoji="${rest%%:*}"
      local name="${rest#*:}"

      if [[ "$_update_all" == true ]] || _update_ask "${emoji} ${name}"; then
        _update_run "$key"
      else
        _update_skip "$name"
      fi
    done
  fi

  # Optional dock rebuild
  if [[ "$_dock" == true ]]; then
    _update_header "🚢" "Dock"
    _mkdock
    _update_success "Dock"
  fi

  _update_summary
  _update_herdr_server_check
}

# ── Tab Completion ─────────────────────────────────────────
# Auto-registered by 70-functions.zsh (compdef _update update)

_update() {
  local state
  _arguments -s \
    '(-y --all)'{-y,--all}'[Update all without prompting]' \
    '(-d --dock)'{-d,--dock}'[Rebuild dock after updates]' \
    '(-r --restart-herdr)'{-r,--restart-herdr}'[Restart herdr server at the end if outdated]' \
    '*:target:->targets'

  if [[ "$state" == "targets" ]]; then
    local -a targets=('help:Show help with available targets')
    local entry
    for entry in "${_UPDATE_TARGETS[@]}"; do
      local key="${entry%%:*}"
      local rest="${entry#*:}"
      local desc="${rest#*:}"
      targets+=("${key}:${desc}")
    done
    _describe 'update target' targets
  fi
}

# ── Outdated ────────────────────────────────────────────────

outdated() {
  echo "\033[1;37mFormulae:\033[0m"
  brew outdated --formula
  echo ""
  echo "\033[1;37mCasks:\033[0m"
  brew outdated --cask --greedy-auto-updates
}
