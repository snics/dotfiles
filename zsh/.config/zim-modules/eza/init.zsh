if (( ! ${+commands[eza]} )); then
  if (( ${+commands[exa]} )); then
    export EXA_COLORS='da=1;34:gm=1;34'
    eza() { exa "$@" }
  else
    return 1
  fi
fi

if [[ -f "${0:h}/functions/_eza" ]]; then
  source "${0:h}/functions/_eza"
else
  echo "Completion file not found: ${0:h}/functions/_eza"
fi

typeset -a _EZA_HEAD
typeset -a _EZA_TAIL

function _configure_eza() {
  local _val
  # Get the head flags
  if zstyle -T ':zim:plugins:eza' 'show-group'; then
    _EZA_HEAD+=("g")
  fi
  if zstyle -t ':zim:plugins:eza' 'header'; then
    _EZA_HEAD+=("h")
  fi
  zstyle -s ':zim:plugins:eza' 'size-prefix' _val
  case "${_val:l}" in
    binary)
      _EZA_HEAD+=("b")
      ;;
    none)
      _EZA_HEAD+=("B")
      ;;
  esac
  # Get the tail long-options
  if zstyle -t ':zim:plugins:eza' 'dirs-first'; then
    _EZA_TAIL+=("--group-directories-first")
  fi
  if eza --git /dev/null &>/dev/null; then
    _EZA_TAIL+=("--git")
  fi
  if zstyle -t ':zim:plugins:eza' 'icons'; then
    _EZA_TAIL+=("--icons=auto")
  fi
  zstyle -s ':zim:plugins:eza' 'time-style' _val
  if [[ $_val ]]; then
    _EZA_TAIL+=("--time-style='$_val'")
  fi
  if zstyle -t ":zim:plugins:eza" "hyperlink"; then
    _EZA_TAIL+=("--hyperlink")
  fi
}

_configure_eza
export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'

function _alias_eza() {
  local _head="${(j::)_EZA_HEAD}$2"
  local _tail="${(j: :)_EZA_TAIL}"
  alias "$1"="eza${_head:+ -}${_head}${_tail:+ }${_tail}${3:+ }$3"

  if declare -F __eza > /dev/null; then
    compdef __eza "$1"
  fi
}

# ls aliases
_alias_eza ls # Short format
_alias_eza la la # Long format, all files
_alias_eza ldot ld ".*" # Long format, hidden files
_alias_eza lD lD # Long format, directories
_alias_eza lDD lDa # Long format, directories and all files
_alias_eza ll l # Long format
_alias_eza lsd d # Short format, directories
_alias_eza lsdl dl # Short format, directories and long format
_alias_eza lS "l -ssize" # Long format, sorted by size
_alias_eza lT "l -snewest" # Long format, sorted by newest
_alias_eza l l -a # Long format, all files
_alias_eza lr l -T # Long format, recursive as a tree
_alias_eza lx l -sextension # Long format, sort by extension
_alias_eza lk l -ssize # Long format, largest file size last
_alias_eza lt l -smodified # Long format, newest modification time last
_alias_eza lc l -schanged # Long format, newest status change (ctime) last

# Tree aliases
_alias_eza tree "" "--tree" # Tree format

unfunction _alias_eza
unfunction _configure_eza
unset _EZA_HEAD
unset _EZA_TAIL