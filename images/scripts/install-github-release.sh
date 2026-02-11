#!/bin/sh
# install-github-release.sh — Download and install a binary from a GitHub release
#
# Usage: install-github-release.sh <repo> <version> <amd64-asset> <arm64-asset> <binary-name>
#
# Example:
#   install-github-release.sh "jesseduffield/lazygit" "v0.44.1" \
#     "lazygit_0.44.1_Linux_x86_64.tar.gz" \
#     "lazygit_0.44.1_Linux_arm64.tar.gz" \
#     "lazygit"

set -eu

REPO="$1"
VERSION="$2"
AMD64_ASSET="$3"
ARM64_ASSET="$4"
BINARY="$5"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  ASSET="$AMD64_ASSET" ;;
  aarch64) ASSET="$ARM64_ASSET" ;;
  *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"
TMPDIR=$(mktemp -d)

echo "Installing ${BINARY} ${VERSION} (${ARCH})..."
curl -fsSL "$URL" -o "${TMPDIR}/archive"

cd "$TMPDIR"
case "$ASSET" in
  *.tar.gz|*.tgz)   tar xzf archive ;;
  *.tar.bz2|*.tbz)  tar xjf archive ;;
  *.zip)             unzip -q archive ;;
  *)                 echo "Unknown archive format: $ASSET" >&2; exit 1 ;;
esac

# Find the binary (may be nested in subdirectories)
FOUND=$(find . -name "$BINARY" -type f -executable 2>/dev/null | head -1)
if [ -z "$FOUND" ]; then
  # Some archives don't set executable bit — try without -executable
  FOUND=$(find . -name "$BINARY" -type f | head -1)
fi

if [ -z "$FOUND" ]; then
  echo "Binary '$BINARY' not found in archive" >&2
  ls -laR "$TMPDIR" >&2
  exit 1
fi

cp "$FOUND" "/usr/local/bin/${BINARY}"
chmod +x "/usr/local/bin/${BINARY}"
rm -rf "$TMPDIR"

echo "Installed ${BINARY} ${VERSION} → /usr/local/bin/${BINARY}"
