#!/bin/bash
set -e

REPO="scanopy/scanopy"
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

BINARY_NAME="scanopy-daemon-${PLATFORM}-${ARCH}"

echo "Installing Scanopy daemon..."
echo "Platform: $PLATFORM"
echo "Architecture: $ARCH"
echo "Binary: $BINARY_NAME"
echo ""

# Download latest binary
BINARY_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}"
echo "Downloading from: $BINARY_URL"

if ! curl -fL "$BINARY_URL" -o scanopy-daemon; then
    echo "Error: Failed to download binary from $BINARY_URL"
    echo "Please check:"
    echo "  1. Your internet connection"
    echo "  2. That a release exists for your platform"
    echo "  3. GitHub releases: https://github.com/${REPO}/releases/latest"
    exit 1
fi

chmod +x scanopy-daemon

# Install to system
echo "Installing to /usr/local/bin (may require sudo)..."
if [ -w "/usr/local/bin" ]; then
    mv scanopy-daemon /usr/local/bin/
else
    sudo mv scanopy-daemon /usr/local/bin/ || {
        echo "Error: Failed to install scanopy-daemon. Please check sudo permissions."
        rm -f scanopy-daemon
        exit 1
    }
fi

# Verify installation
if [ ! -f "/usr/local/bin/scanopy-daemon" ]; then
    echo "Error: Installation verification failed."
    exit 1
fi

echo ""
echo "✓ Scanopy daemon installed successfully!"
echo ""

# Ask about systemd service installation (Linux only)
if [ "$PLATFORM" = "linux" ] && command -v systemctl &> /dev/null; then
    echo "Would you like to install Scanopy daemon as a systemd service?"
    echo "This will allow the daemon to:"
    echo "  - Start automatically on boot"
    echo "  - Run in the background"
    echo "  - Restart automatically if it crashes"
    echo ""
    read -p "Install as systemd service? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Installing systemd service..."
        
        # Download service file
        SERVICE_URL="https://raw.githubusercontent.com/${REPO}/main/scanopy-daemon.service"
        
        if ! curl -fL "$SERVICE_URL" -o scanopy-daemon.service; then
            echo "Warning: Failed to download service file from $SERVICE_URL"
            echo "You can manually install the service later."
        else
            # Install service file
            sudo mv scanopy-daemon.service /etc/systemd/system/ || {
                echo "Error: Failed to install service file."
                rm -f scanopy-daemon.service
                exit 1
            }
            
            echo ""
            echo "✓ Systemd service file installed!"
            echo ""
            echo "⚠️  IMPORTANT: You must edit the service file with your daemon configuration:"
            echo ""
            echo "  sudo nano /etc/systemd/system/scanopy-daemon.service"
            echo ""
            echo "Add your daemon arguments to the ExecStart line:"
            echo "  ExecStart=/usr/local/bin/scanopy-daemon --server-url http://YOUR_SERVER --server-port 60072 --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY"
            echo ""
            echo "Then enable and start the service:"
            echo "  sudo systemctl daemon-reload"
            echo "  sudo systemctl enable scanopy-daemon"
            echo "  sudo systemctl start scanopy-daemon"
            echo ""
            echo "Check status:"
            echo "  sudo systemctl status scanopy-daemon"
            echo ""
            echo "View logs:"
            echo "  sudo journalctl -u scanopy-daemon -f"
            echo ""
        fi
    fi
fi

# Show manual run instructions
echo ""
echo "To run daemon manually:"
echo "  scanopy-daemon --server-url YOUR_SERVER_URL"
echo ""
echo "Need help? Visit: https://github.com/${REPO}#readme"
