# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="z .."
alias ...="z ../.."
alias ....="z ../../.."
alias .....="z ../../../.."
alias ~="z ~"
alias -- -="z -"

# Get week number
alias week='date +%V'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Recursively delete `.DS_Store` files
alias clean="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple's System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Zoxide shortcuts (zim-zoxide uses --cmd cd, so z/zi don't exist by default)
alias z="cd"
alias zi="cdi"

# Clear terminal
alias cl="clear"

# NeoVim
alias vim="nvim"
alias vi="nvim"

# Docker Compose (dc prefix — OMZ docker plugin handles direct aliases with d prefix)
alias dcup='docker compose up'
alias dcdown='docker compose down'
alias dcbuild='docker compose build'
alias dcrestart='docker compose restart'
alias dclogs='docker compose logs'
alias dcps='docker compose ps'
alias dcconfig='docker compose config'
alias dcexec='docker compose exec'

# Podman Compose (pc prefix — OMZ podman plugin handles direct aliases with p prefix)
alias pcup='podman-compose up'
alias pcdown='podman-compose down'
alias pcbuild='podman-compose build'
alias pcrestart='podman-compose restart'
alias pclogs='podman-compose logs'
alias pcps='podman-compose ps'
alias pcconfig='podman-compose config'
alias pcexec='podman-compose exec'

# App aliases
alias claude-mem='bun "/Users/nico/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
