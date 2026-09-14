#!/usr/bin/env bash
# =============================================================================
# Touch ID for sudo
# =============================================================================
#
# Installs /etc/pam.d/sudo_local so every sudo prompt becomes a Touch ID tap
# instead of a typed password. Apple added sudo_local in macOS Sonoma exactly
# for this: unlike /etc/pam.d/sudo it survives OS updates.
#
# pam_reattach (brew "pam-reattach", Brewfile.80-misc) reattaches the process
# to the user session so Touch ID also works inside tmux/herdr sessions.
# ignore_ssh skips the reattach for SSH logins, where Touch ID cannot work.
#
# Idempotent: skips installation when sudo_local already has this content.
# Requires sudo once (ironically, via password — the last time you type it).
# =============================================================================

set -euo pipefail

PAM_REATTACH="/opt/homebrew/lib/pam/pam_reattach.so"
TARGET="/etc/pam.d/sudo_local"

if [[ ! -f "$PAM_REATTACH" ]]; then
  echo "pam_reattach.so not found — run 'brew install pam-reattach' first." >&2
  exit 1
fi

content="$(cat <<EOF
# sudo_local: Touch ID for sudo. This file survives macOS updates
# (unlike /etc/pam.d/sudo). pam_reattach makes Touch ID work inside
# tmux/herdr sessions; ignore_ssh skips it for SSH logins.
auth       optional       ${PAM_REATTACH} ignore_ssh
auth       sufficient     pam_tid.so
EOF
)"

if [[ -f "$TARGET" ]] && [[ "$(cat "$TARGET")" == "$content" ]]; then
  echo "Touch ID for sudo already configured ($TARGET)."
  exit 0
fi

echo "Installing $TARGET (Touch ID for sudo)..."
printf '%s\n' "$content" | sudo tee "$TARGET" >/dev/null
sudo chown root:wheel "$TARGET"
sudo chmod 0444 "$TARGET"
echo "Done. Test with: sudo -k && sudo true  (should prompt Touch ID)"
