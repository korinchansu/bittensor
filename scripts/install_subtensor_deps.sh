#!/bin/bash

# Function to check if Rust and Cargo are installed
check_rust_and_cargo() {
    if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
        return 0 # Rust and Cargo are installed
    else
        return 1 # Either Rust or Cargo or both are not installed
    fi
}

# Check Rust and Cargo installation
if check_rust_and_cargo; then
    echo "Rust and Cargo are already installed."
else
    echo "Rust and/or Cargo not found. Installing dependencies and Rust..."

    # Update and install dependencies
    sudo apt update
    sudo apt install -y git clang curl libssl-dev llvm libudev-dev

    # Install Rust and Cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source ~/.cargo/env

    # Configure Rust toolchain
    rustup default stable
    rustup update
    rustup update nightly
    rustup target add wasm32-unknown-unknown --toolchain nightly

    # Build with Cargo
    cargo run --release --bin node-subtensor -- --dev
    cargo build --release
fi
