#!/usr/bin/env bash
#
# Keep the clauth daemon alive with launchd.
#
# The daemon is the only process that re-stamps the rolling bearer (see
# clauth/AGENTS.md, "The rolling token"). Without it, Claude Code is signed
# out within ~8 h. Until now it was only started by the first herdr pane
# (zsh/conf.d/66-clauth.zsh), so when it exited — its watchdog aborts after
# sleep/wake "for a clean launchd restart", and it has also died silently —
# nothing brought it back until the next pane opened. Diagnosis:
# _planning/clauth-relogin-diagnosis.md.
#
# The agent runs `clauth daemon --standby`: if a daemon already runs (e.g.
# one spawned by a herdr pane), it waits and takes over when that one exits,
# instead of exiting at once and making KeepAlive respawn it in a loop.
#
# Loading the agent starts a daemon, and Daemon::boot relinks the active
# profile's credentials into the login Keychain. Run this deliberately, not
# from bootstrap.
#
# Usage: clauth-daemon.sh            install/refresh and load the agent
#        clauth-daemon.sh --remove   unload and delete it

set -euo pipefail

LABEL="com.dotfiles.clauth-daemon"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

if [[ "${1:-}" == "--remove" ]]; then
    launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "  removed $LABEL"
    exit 0
fi

CLAUTH="$(command -v clauth || true)"
if [[ -z "$CLAUTH" ]]; then
    echo "  ERROR: clauth not found on PATH — run 'just cargo-tools' first."
    exit 1
fi
if [[ -z "$(ls -A "$HOME/.clauth/profiles" 2>/dev/null)" ]]; then
    echo "  ERROR: no clauth profile enrolled — run 'clauth login <name>' first."
    exit 1
fi

# The plist needs absolute paths, so it is generated here instead of tracked.
mkdir -p "$(dirname "$PLIST")"
tmp="$(mktemp)"
cat > "$tmp" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$CLAUTH</string>
        <string>daemon</string>
        <string>--standby</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$(dirname "$CLAUTH"):/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ThrottleInterval</key>
    <integer>30</integer>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardOutPath</key>
    <string>$HOME/.clauth/daemon.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.clauth/daemon.log</string>
</dict>
</plist>
EOF
plutil -lint "$tmp" >/dev/null

if [[ -f "$PLIST" ]] && cmp -s "$tmp" "$PLIST"; then
    rm -f "$tmp"
    echo "  $LABEL unchanged"
else
    mv -f "$tmp" "$PLIST"
    launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
    echo "  wrote $PLIST"
fi

if ! launchctl print "$DOMAIN/$LABEL" &>/dev/null; then
    launchctl bootstrap "$DOMAIN" "$PLIST"
    echo "  loaded $LABEL"
fi

echo "Done. Check with: clauth daemon --status; tail ~/.clauth/daemon.log"
