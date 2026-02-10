# Fallback completions for tools without native zsh completion support.
# Uses zsh's built-in _gnu_generic which parses --help output on first
# tab-press (cached in-memory for the rest of the session).
# Zero startup cost, full fzf-tab compatibility.

() {
  local cmd
  local -a tools=(
    # DevOps / Cloud
    dockle        # Container image linter
    dockutil      # macOS dock management
    krr           # Kubernetes Resource Reporter
    mackup        # macOS app settings backup
    mas           # Mac App Store CLI
    podman-compose # Podman Compose
    rancher       # Rancher CLI
    reg           # Docker registry client
    rke           # Rancher Kubernetes Engine
    s3cmd         # S3 command-line tool

    # Dev tools
    bfg           # Git history cleaner
    cloc          # Count lines of code
    exiv2         # Image metadata tool
    gopls         # Go language server
    gox           # Go cross-compile
    hadolint      # Dockerfile linter
    pkgx          # Package runner
    gemini        # Google Gemini CLI

    # Security / Pentest
    aircrack-ng   # WiFi security suite
    binwalk       # Firmware analysis
    cifer         # Encryption tool
    clair         # Container vulnerability scanner
    fcrackzip     # ZIP password cracker
    foremost      # File recovery
    hashpump      # Hash length extension
    hydra         # Network logon cracker
    john          # Password cracker
    lynis         # Security auditing
    sqlmap        # SQL injection tool
    sysdig        # System exploration

    # Network / Analysis
    socat         # Multipurpose relay
    tcpflow       # TCP connection capture
    tcpreplay     # Network traffic replay
    tcptrace      # tcpdump analyzer

    # TUIs (minimal flags, but still nice to complete)
    btop          # Resource monitor
    ctop          # Container metrics
    lazygit       # Git TUI
    lazydocker    # Docker TUI
    peco          # Interactive filter

    # Utilities
    pngcheck      # PNG integrity checker
    rename        # Batch file rename
    rlwrap        # Readline wrapper
    vbindiff      # Visual binary diff
    wdiff         # Word diff
  )

  for cmd in "${tools[@]}"; do
    # Only register if installed and no existing completion
    if (( $+commands[$cmd] )) && (( ! $+_comps[$cmd] )); then
      compdef _gnu_generic "$cmd"
    fi
  done
}
