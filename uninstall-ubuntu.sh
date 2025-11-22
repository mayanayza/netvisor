#!/bin/bash
set -e

# NetVisor Ubuntu Uninstallation Script

INSTALL_DIR="/opt/netvisor"
CONFIG_DIR="/etc/netvisor"
DATA_DIR="/var/lib/netvisor"
LOG_DIR="/var/log/netvisor"
DAEMON_USER="netvisor"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          NetVisor Ubuntu Uninstallation                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

print_warning "This will remove NetVisor and all its data!"
read -p "Are you sure you want to continue? (yes/NO) " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

# Ask about database
echo ""
read -p "Do you want to remove the PostgreSQL database? (yes/NO) " -r
REMOVE_DB=$REPLY
echo ""

# Stop services
print_info "Stopping services..."
systemctl stop netvisor-daemon 2>/dev/null || true
systemctl stop netvisor-server 2>/dev/null || true
systemctl disable netvisor-daemon 2>/dev/null || true
systemctl disable netvisor-server 2>/dev/null || true
print_success "Services stopped"

# Remove systemd services
print_info "Removing systemd service files..."
rm -f /etc/systemd/system/netvisor-server.service
rm -f /etc/systemd/system/netvisor-daemon.service
systemctl daemon-reload
print_success "Service files removed"

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    print_info "Removing installation directory: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
    print_success "Installation directory removed"
fi

# Remove configuration
if [ -d "$CONFIG_DIR" ]; then
    print_info "Removing configuration directory: $CONFIG_DIR"
    rm -rf "$CONFIG_DIR"
    print_success "Configuration directory removed"
fi

# Remove data directory
if [ -d "$DATA_DIR" ]; then
    print_warning "Removing data directory: $DATA_DIR (this includes all your network data!)"
    rm -rf "$DATA_DIR"
    print_success "Data directory removed"
fi

# Remove logs
if [ -d "$LOG_DIR" ]; then
    print_info "Removing log directory: $LOG_DIR"
    rm -rf "$LOG_DIR"
    print_success "Log directory removed"
fi

# Remove system user
if id "$DAEMON_USER" &>/dev/null; then
    print_info "Removing system user: $DAEMON_USER"
    userdel "$DAEMON_USER" 2>/dev/null || true
    print_success "System user removed"
fi

# Remove database if requested
if [[ $REMOVE_DB =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Removing PostgreSQL database..."
    sudo -u postgres psql << EOF
DROP DATABASE IF EXISTS netvisor;
DROP USER IF EXISTS netvisor;
EOF
    print_success "Database removed"
else
    print_info "Database preserved (can be removed manually with: sudo -u postgres psql -c 'DROP DATABASE netvisor; DROP USER netvisor;')"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Uninstallation Complete!                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
print_success "NetVisor has been uninstalled"
echo ""
print_info "Note: The following were NOT removed:"
echo "  - Rust toolchain (/usr/local/cargo)"
echo "  - Node.js"
echo "  - PostgreSQL server"
echo "  - Build dependencies (build-essential, etc.)"
echo ""
print_info "To remove these manually:"
echo "  sudo rm -rf /usr/local/cargo /usr/local/rustup"
echo "  sudo apt remove nodejs postgresql"
echo ""
