#!/bin/bash
set -e

REPO="mayanayza/netvisor"
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names to match release binaries
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        echo "Supported architectures: x86_64 (amd64), aarch64/arm64"
        exit 1
        ;;
esac

BINARY_NAME="netvisor-daemon-${PLATFORM}-${ARCH}"

echo "Installing NetVisor daemon..."
echo "Platform: $PLATFORM"
echo "Architecture: $ARCH"
echo "Binary: $BINARY_NAME"
echo ""

# Download latest binary
BINARY_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}"
echo "Downloading from: $BINARY_URL"

if ! curl -fL "$BINARY_URL" -o netvisor-daemon; then
    echo "Error: Failed to download binary from $BINARY_URL"
    echo "Please check:"
    echo "  1. Your internet connection"
    echo "  2. That a release exists for your platform"
    echo "  3. GitHub releases: https://github.com/${REPO}/releases/latest"
    exit 1
fi

chmod +x netvisor-daemon

# Install to system
echo "Installing to /usr/local/bin (may require sudo)..."
if [ -w "/usr/local/bin" ]; then
    mv netvisor-daemon /usr/local/bin/
else
    sudo mv netvisor-daemon /usr/local/bin/ || {
        echo "Error: Failed to install netvisor-daemon. Please check sudo permissions."
        rm -f netvisor-daemon
        exit 1
    }
fi

# Verify installation
if [ ! -f "/usr/local/bin/netvisor-daemon" ]; then
    echo "Error: Installation verification failed."
    exit 1
fi

echo ""
echo "✓ NetVisor daemon installed successfully!"
echo ""
echo "To run daemon: netvisor-daemon --server-target YOUR_SERVER_IP --server-port 60072"
echo ""
echo "Need help? Visit: https://github.com/${REPO}#readme"