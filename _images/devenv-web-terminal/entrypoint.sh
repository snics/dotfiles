#!/bin/bash
set -e

# Catppuccin Macchiato — https://github.com/catppuccin/catppuccin
# TODO: Migrate to ghostty-web once v1.0 ships with libghostty-vt WASM support.
#       This would give us the same terminal emulator in browser as on desktop (Ghostty).
#       Track: https://github.com/coder/ghostty-web (currently v0.4.0, pre-1.0)
#       Track: https://mitchellh.com/writing/libghostty-is-coming
CATPPUCCIN_THEME='{
  "background":"#24273a","foreground":"#cad3f5","cursor":"#f4dbd6","cursorAccent":"#24273a",
  "selectionBackground":"#5b6078","selectionForeground":"#cad3f5",
  "black":"#494d64","red":"#ed8796","green":"#a6da95","yellow":"#eed49f",
  "blue":"#8aadf4","magenta":"#f5bde6","cyan":"#8bd5ca","white":"#b8c0e0",
  "brightBlack":"#5b6078","brightRed":"#ed8796","brightGreen":"#a6da95","brightYellow":"#eed49f",
  "brightBlue":"#8aadf4","brightMagenta":"#f5bde6","brightCyan":"#8bd5ca","brightWhite":"#a5adcb"
}'

TTYD_OPTS=(
  -W
  -p 7681
  -t "titleFixed=snic/devenv-web-terminal"
  -t "fontSize=14"
  -t "fontFamily=Lilex Nerd Font,Lilex Nerd Font Mono,JetBrains Mono,Menlo,monospace"
  -t "theme=${CATPPUCCIN_THEME}"
  -t "cursorBlink=true"
)

# If a workspace directory is mounted, start there
if [ -d "${HOME}/workspace" ]; then
  cd "${HOME}/workspace" || true
fi

case "${TTYD_MODE}" in
  terminal)
    exec ttyd "${TTYD_OPTS[@]}" zsh -l
    ;;
  tmux)
    exec ttyd "${TTYD_OPTS[@]}" tmux new-session -A -s main
    ;;
  nvim)
    exec ttyd "${TTYD_OPTS[@]}" nvim
    ;;
  *)
    # Custom: treat TTYD_MODE as the command itself
    exec ttyd "${TTYD_OPTS[@]}" "${TTYD_MODE}"
    ;;
esac
