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
# Usage:
#   update              Interactive mode (prompts per target)
#   update -y           Update everything without prompting
#   update brew         Only update Homebrew
#   update brew zsh     Update Homebrew and Zsh
#   update -y -d        Update everything + rebuild dock
#   update help         Show help with available targets
#

# ── Sudo Keepalive ──────────────────────────────────────────
# Asks for password once, stores it securely in a temp file (mode 600),
# and re-authenticates automatically when Homebrew resets the sudo cache.
# See: https://github.com/Homebrew/brew/issues/17912
#
# How it works:
# 1. Prompt for password once, verify it, store base64-encoded in a temp file
# 2. Background keepalive refreshes the sudo cache every 50s
# 3. _sudo_refresh re-authenticates via `sudo -S` after Homebrew resets
# 4. Everything is cleaned up securely on exit

typeset -g _SUDO_KEEPALIVE_PID=""
typeset -g _SUDO_PW_FILE=""

_update_sudo_start() {
  # Read the password once (hidden input)
  local _pw
  read -rs "_pw?Password: "
  echo ""

  # Verify the password works
  if ! echo "$_pw" | sudo -S true 2>/dev/null; then
    echo "sudo: authentication failed" >&2
    return 1
  fi

  # Store password base64-encoded in a secure temp file (owner-only)
  # Use >| to bypass noclobber (mktemp already creates the file)
  _SUDO_PW_FILE="$(mktemp "${TMPDIR:-/tmp}/.upd_auth.XXXXXX")"
  chmod 600 "$_SUDO_PW_FILE"
  echo -n "$_pw" | base64 >| "$_SUDO_PW_FILE"
  unset _pw

  # Background keepalive: inline script via /bin/sh -c (no temp file needed)
  # PID is captured via a temp file to avoid zsh subshell/pipe variable scoping issues
  local _pw_file="$_SUDO_PW_FILE"
  local _parent_pid="$$"
  local _pid_file="$(mktemp "${TMPDIR:-/tmp}/.upd_proc.XXXXXX")"
  (
    /bin/sh -c '
      while true; do
        sleep 50
        if ! sudo -n -v 2>/dev/null; then
          base64 -d < "'"$_pw_file"'" | sudo -S -v 2>/dev/null || exit 0
        fi
        kill -0 '"$_parent_pid"' 2>/dev/null || exit 0
      done
    ' &>/dev/null &
    echo $! >| "$_pid_file"
  )
  _SUDO_KEEPALIVE_PID=$(<"$_pid_file")
  rm -f "$_pid_file"
}

# Re-authenticate after Homebrew resets the sudo timestamp
_sudo_refresh() {
  if ! sudo -n -v 2>/dev/null; then
    base64 -d < "$_SUDO_PW_FILE" | sudo -S -v 2>/dev/null
  fi
}

_update_sudo_stop() {
  # Kill keepalive process
  if [[ -n "$_SUDO_KEEPALIVE_PID" ]] && kill -0 "$_SUDO_KEEPALIVE_PID" 2>/dev/null; then
    kill -TERM "$_SUDO_KEEPALIVE_PID" 2>/dev/null
  fi
  _SUDO_KEEPALIVE_PID=""

  # Securely remove password file
  if [[ -n "$_SUDO_PW_FILE" ]]; then
    rm -Pf "$_SUDO_PW_FILE" 2>/dev/null || rm -f "$_SUDO_PW_FILE"
    _SUDO_PW_FILE=""
  fi

  # Invalidate sudo cache on exit
  sudo -k 2>/dev/null

  trap - EXIT INT TERM HUP
}

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
  brew update
  _sudo_refresh
  echo "Upgrading from Brewfile..."
  brew bundle
  _sudo_refresh
  echo "Upgrading Cask apps (greedy)..."
  brew upgrade --cask --greedy
  _sudo_refresh
  echo "Cleaning up..."
  brew cleanup
  _update_success "Homebrew"
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

_update_tmux() {
  local tpm_update="$HOME/.tmux/plugins/tpm/bin/update_plugins"
  if [[ ! -f "$tpm_update" ]]; then
    _update_not_found "Tmux Plugins"
    return
  fi
  _update_header "🖥️" "Tmux Plugins"
  echo "Updating TPM plugins..."
  "$tpm_update" all
  _update_success "Tmux Plugins"
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

_update_zsh() {
  _update_header "🐚" "Zsh/Zim"
  echo "Updating Zim modules..."
  zimfw update
  echo "Upgrading Zim framework..."
  zimfw upgrade
  _update_success "Zsh/Zim"
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
    tmux)   _update_tmux ;;
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
  "tmux:🖥️:Tmux Plugins"
  "krew:☸️:Krew"
  "zsh:🐚:Zsh/Zim"
)

# ── Help ────────────────────────────────────────────────────

_update_help() {
  echo ""
  echo "\033[1;37mUsage:\033[0m update [options] [targets...]"
  echo ""
  echo "\033[1;37mOptions:\033[0m"
  echo "  -y, --all    Update all without prompting"
  echo "  -d, --dock   Rebuild dock after updates"
  echo "  help         Show this help message"
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
  echo "  rust         Rust toolchain (rustup)"
  echo "  nvim         Neovim plugins (lazy.nvim)"
  echo "  tmux         Tmux plugins (TPM)"
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
  command -v tmux &>/dev/null   && echo "  tmux         $(tmux -V 2>/dev/null)"
  command -v kubectl &>/dev/null && echo "  kubectl      $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"
  command -v zimfw &>/dev/null  && echo "  zimfw        $(zimfw version 2>/dev/null)"
  echo ""
}

# ── Main Function ───────────────────────────────────────────

update() {
  local _update_all=false
  local _dock=false
  local -a _targets=()
  _update_results=()

  # Parse arguments
  for arg in "$@"; do
    case $arg in
      -y|--all)  _update_all=true ;;
      -d|--dock) _dock=true ;;
      help)      _update_help; return 0 ;;
      *)         _targets+=("$arg") ;;
    esac
  done

  # Start sudo keepalive
  _update_sudo_start || return 1
  trap '_update_sudo_stop' EXIT INT TERM HUP

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
  _update_sudo_stop
}

# ── Tab Completion ─────────────────────────────────────────
# Auto-registered by 70-functions.zsh (compdef _update update)

_update() {
  local state
  _arguments -s \
    '(-y --all)'{-y,--all}'[Update all without prompting]' \
    '(-d --dock)'{-d,--dock}'[Rebuild dock after updates]' \
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
  brew outdated --cask --greedy
}
