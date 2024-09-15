#!/usr/bin/env zsh

# Spinner-Definitionen
local -A _revolver_spinners
_revolver_spinners=(
  'dots' '0.08 ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏'
  'line' '0.13 - \\ | /'
)

# Spinner-Start-Funktion
_revolver_start() {
  local msg="$1"
  local pid=$$
  local spinner_index=1
  local frames=(${(z)_revolver_spinners[dots]})
  local interval=${frames[1]}
  shift frames

  # Spinner-Prozess
  (
    trap "exit" INT TERM  # Neu: Traps zur Prozessverwaltung
    trap "kill 0" EXIT

    while true; do
      local frame=${frames[$spinner_index]}
      printf "\r%s %s" "$frame" "$msg"
      sleep $interval
      spinner_index=$((spinner_index % ${#frames[@]} + 1))
    done
  ) &
  echo $! > /tmp/revolver.$pid
}

# Spinner-Stop-Funktion
_revolver_stop() {
  local pid=$$
  if [[ -f /tmp/revolver.$pid ]]; then
    kill $(cat /tmp/revolver.$pid) 2>/dev/null
    rm /tmp/revolver.$pid
    printf "\r    \r"  # Neu: Bereinigung der Ausgabe
  fi
}

# Hauptfunktion
revolver() {
  case "$1" in
    start) _revolver_start "$2" ;;
    stop) _revolver_stop ;;
    *) echo "Usage: revolver {start|stop} [message]" ;;
  esac
}

# Beispielaufruf
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  revolver "$@"
fi
