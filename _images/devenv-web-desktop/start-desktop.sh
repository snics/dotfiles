#!/bin/bash
set -e

# Create XDG_RUNTIME_DIR for PulseAudio and D-Bus (must be owned by developer)
mkdir -p /tmp/developer-run
chown developer:developer /tmp/developer-run
chmod 700 /tmp/developer-run

# Create ICE and X11 unix socket directories (XFCE4 session management)
mkdir -p /tmp/.ICE-unix /tmp/.X11-unix
chmod 1777 /tmp/.ICE-unix /tmp/.X11-unix

# Start system D-Bus — explicitly use /usr/bin/ to avoid Homebrew's dbus-daemon
# which places the socket under /home/linuxbrew/... instead of /run/dbus/.
mkdir -p /run/dbus
rm -f /run/dbus/pid
/usr/bin/dbus-daemon --system --nofork &

# Wait for system bus socket
for i in $(seq 1 30); do
    [ -S /run/dbus/system_bus_socket ] && break
    sleep 0.2
done

if [ ! -S /run/dbus/system_bus_socket ]; then
    echo "ERROR: system D-Bus socket not available after 6s" >&2
    exit 1
fi

# Create a session D-Bus bus for the developer user and export its address.
# Use /usr/bin/ here too to ensure the session bus is created by system dbus tools.
# All supervisord child processes inherit this, giving xfce4-session, selkies,
# and PulseAudio a shared session bus via %(ENV_DBUS_SESSION_BUS_ADDRESS)s.
eval "$(su -s /bin/bash developer -c '/usr/bin/dbus-launch --sh-syntax')"
export DBUS_SESSION_BUS_ADDRESS

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/desktop.conf
