#!/usr/bin/env bash

echo "Install Rust...."

# Install rustup with stable as default toolchain
rustup-init --default-toolchain=stable -y

# Source cargo env for current session
source "$HOME/.cargo/env"

# Install essential components for stable
rustup component add \
    rust-analyzer \
    clippy \
    rustfmt \
    rust-src

# Install nightly toolchain (for projects that need it)
rustup toolchain install nightly

# Install essential components for nightly
rustup component add \
    rust-analyzer \
    clippy \
    rustfmt \
    rust-src \
    --toolchain nightly

# Cargo tools are NOT installed here.
#   - Everything available as a formula (cargo-watch, cargo-edit, cargo-nextest,
#     cargo-zigbuild, cargo-binstall) lives in brew/Brewfile.20-dev-tools, so
#     `brew bundle cleanup` can account for it.
#   - Crates with no formula are declared in _install/cargo-tools.list and
#     installed by _install/cargo-tools.sh (`just cargo-tools`).

echo "Install Rust done!"
echo "  Default toolchain: stable"
echo "  Nightly available: rustup run nightly cargo build"
echo "  Per-project override: rustup override set nightly"
echo "  Cargo tools: brew bundle (formulae) + just cargo-tools (the rest)"
