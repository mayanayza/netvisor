#!/bin/bash
set -e

# NetVisor Ubuntu Build Script
# Builds NetVisor binaries and UI without installing as a service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required tools
check_dependencies() {
    print_info "Checking build dependencies..."

    local missing_deps=()

    # Check Rust
    if ! command -v rustc &> /dev/null; then
        missing_deps+=("Rust")
    fi

    # Check Cargo
    if ! command -v cargo &> /dev/null; then
        missing_deps+=("Cargo")
    fi

    # Check Node.js
    if ! command -v node &> /dev/null; then
        missing_deps+=("Node.js")
    else
        node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -lt 20 ]; then
            print_error "Node.js version 20 or higher required (found v$node_version)"
            exit 1
        fi
    fi

    # Check npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Install dependencies:"
        echo "  Rust:    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo "  Node.js: https://nodejs.org/ or use NodeSource: https://github.com/nodesource/distributions"
        echo ""
        echo "Or run the full installation script: sudo ./install-ubuntu.sh"
        exit 1
    fi

    print_success "All build dependencies found"
}

# Build backend
build_backend() {
    print_info "Building backend (server + daemon)..."
    echo "This may take 10-15 minutes on first build..."
    echo ""

    cd "$SCRIPT_DIR/backend"

    # Build server
    print_info "Building server..."
    cargo build --release --bin server

    # Build daemon
    print_info "Building daemon..."
    cargo build --release --bin daemon

    cd "$SCRIPT_DIR"

    print_success "Backend build complete"
    echo "  Server: backend/target/release/server"
    echo "  Daemon: backend/target/release/daemon"
}

# Build frontend
build_frontend() {
    print_info "Building frontend UI..."

    cd "$SCRIPT_DIR/ui"

    # Install dependencies
    print_info "Installing npm dependencies..."
    npm install

    # Build UI
    print_info "Building production UI..."
    npm run build

    cd "$SCRIPT_DIR"

    print_success "Frontend build complete"
    echo "  Static files: ui/build/"
}

# Main
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              NetVisor Build Script                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    check_dependencies
    echo ""

    # Ask what to build
    if [ "$1" == "backend" ]; then
        build_backend
    elif [ "$1" == "frontend" ]; then
        build_frontend
    elif [ "$1" == "all" ] || [ -z "$1" ]; then
        build_backend
        echo ""
        build_frontend
    else
        print_error "Unknown build target: $1"
        echo "Usage: $0 [all|backend|frontend]"
        exit 1
    fi

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Build Complete!                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    print_success "NetVisor has been built successfully"
    echo ""
    print_info "To run in development mode:"
    echo "  1. Set up PostgreSQL database:"
    echo "     make setup-db"
    echo ""
    echo "  2. Run the server:"
    echo "     cd backend"
    echo "     DATABASE_URL='postgresql://postgres:password@localhost:5432/netvisor' \\"
    echo "       cargo run --bin server"
    echo ""
    echo "  3. Run the daemon (in another terminal):"
    echo "     cd backend"
    echo "     cargo run --bin daemon -- --server-target http://127.0.0.1 --server-port 60072"
    echo ""
    echo "Or install as a system service with:"
    echo "  sudo ./install-ubuntu.sh"
    echo ""
}

main "$@"
