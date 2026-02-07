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

# Install commonly used cargo tools
cargo install cargo-watch   # Auto-rebuild on file changes
cargo install cargo-edit    # `cargo add`, `cargo rm`, `cargo upgrade`
cargo install cargo-nextest # Faster test runner

echo "Install Rust done!"
echo "  Default toolchain: stable"
echo "  Nightly available: rustup run nightly cargo build"
echo "  Per-project override: rustup override set nightly"
