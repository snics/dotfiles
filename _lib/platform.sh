#!/usr/bin/env bash
# Platform detection — source this file, don't execute it
#
# Exports: IS_MACOS, IS_LINUX, IS_CONTAINER, IS_CODESPACES, IS_DEVPOD, HAS_GUI
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/../_lib/platform.sh"
#   if $IS_MACOS; then ... fi

export IS_MACOS=false
export IS_LINUX=false
export IS_CONTAINER=false
export IS_CODESPACES=false
export IS_DEVPOD=false
export HAS_GUI=false

if [[ "$(uname -s)" == "Darwin" ]]; then IS_MACOS=true; fi
if [[ "$(uname -s)" == "Linux" ]];  then IS_LINUX=true; fi

# Container detection (Docker, Podman, Codespaces, DevPod, VS Code Dev Containers)
if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] \
   || [[ "${CODESPACES:-}" == "true" ]] \
   || [[ "${DEVPOD:-}" == "true" ]] \
   || [[ "${REMOTE_CONTAINERS:-}" == "true" ]]; then
  IS_CONTAINER=true
fi

if [[ "${CODESPACES:-}" == "true" ]]; then IS_CODESPACES=true; fi
if [[ "${DEVPOD:-}" == "true" ]];     then IS_DEVPOD=true; fi

# GUI available on macOS (always), Linux only outside containers
if $IS_MACOS; then HAS_GUI=true; fi
