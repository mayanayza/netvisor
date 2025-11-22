#!/bin/bash
set -e

# NetVisor Ubuntu Installation Script
# This script installs NetVisor natively on Ubuntu without Docker

VERSION="0.4.3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/netvisor"
CONFIG_DIR="/etc/netvisor"
DATA_DIR="/var/lib/netvisor"
LOG_DIR="/var/log/netvisor"
DAEMON_USER="netvisor"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
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
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Detect Ubuntu version
check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        print_error "Cannot detect OS version"
        exit 1
    fi

    . /etc/os-release

    if [ "$ID" != "ubuntu" ]; then
        print_warning "This script is designed for Ubuntu, detected: $ID"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_info "Detected: $PRETTY_NAME"
}

# Check system requirements
check_requirements() {
    print_info "Checking system requirements..."

    # Check minimum RAM (2GB)
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 2 ]; then
        print_warning "Recommended minimum 2GB RAM, detected: ${total_ram}GB"
    fi

    # Check disk space (5GB minimum)
    available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 5 ]; then
        print_warning "Recommended minimum 5GB free space, detected: ${available_space}GB"
    fi

    print_success "System requirements check completed"
}

# Install system dependencies
install_dependencies() {
    print_info "Installing system dependencies..."

    apt-get update
    apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        pkg-config \
        libssl-dev \
        postgresql \
        postgresql-contrib \
        sudo \
        ca-certificates \
        gnupg

    print_success "System dependencies installed"
}

# Install Rust
install_rust() {
    print_info "Checking Rust installation..."

    # Check if rustc exists for current user and root
    if command -v rustc >/dev/null 2>&1; then
        rust_version=$(rustc --version)
        print_info "Rust already installed: $rust_version"
        return 0
    fi

    print_info "Installing Rust toolchain..."

    # Install Rust using rustup (non-interactive)
    export RUSTUP_HOME=/usr/local/rustup
    export CARGO_HOME=/usr/local/cargo

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path

    # Add to PATH for current script
    export PATH="/usr/local/cargo/bin:$PATH"

    # Create system-wide profile script
    cat > /etc/profile.d/rust.sh << 'EOF'
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="/usr/local/cargo/bin:$PATH"
EOF

    chmod +x /etc/profile.d/rust.sh

    # Verify installation
    if ! command -v rustc >/dev/null 2>&1; then
        print_error "Rust installation failed"
        exit 1
    fi

    print_success "Rust installed: $(rustc --version)"
}

# Install Node.js
install_nodejs() {
    print_info "Checking Node.js installation..."

    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version)
        major_version=$(echo $node_version | cut -d'v' -f2 | cut -d'.' -f1)

        if [ "$major_version" -ge 20 ]; then
            print_info "Node.js already installed: $node_version"
            return 0
        else
            print_warning "Node.js $node_version is too old, need v20+"
        fi
    fi

    print_info "Installing Node.js 20.x..."

    # Install Node.js 20.x using NodeSource
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
        gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    NODE_MAJOR=20
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | \
        tee /etc/apt/sources.list.d/nodesource.list

    apt-get update
    apt-get install -y nodejs

    # Verify installation
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js installation failed"
        exit 1
    fi

    print_success "Node.js installed: $(node --version)"
}

# Setup PostgreSQL database
setup_database() {
    print_info "Setting up PostgreSQL database..."

    # Start PostgreSQL if not running
    systemctl start postgresql
    systemctl enable postgresql

    # Create database user and database
    sudo -u postgres psql << EOF
-- Create user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'netvisor') THEN
        CREATE USER netvisor WITH PASSWORD '${DB_PASSWORD}';
    END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE netvisor OWNER netvisor'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'netvisor')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE netvisor TO netvisor;
EOF

    # Update pg_hba.conf to allow local connections
    PG_HBA="/etc/postgresql/*/main/pg_hba.conf"
    if [ -f /etc/postgresql/14/main/pg_hba.conf ]; then
        PG_HBA="/etc/postgresql/14/main/pg_hba.conf"
    elif [ -f /etc/postgresql/15/main/pg_hba.conf ]; then
        PG_HBA="/etc/postgresql/15/main/pg_hba.conf"
    elif [ -f /etc/postgresql/16/main/pg_hba.conf ]; then
        PG_HBA="/etc/postgresql/16/main/pg_hba.conf"
    fi

    # Backup pg_hba.conf
    cp "$PG_HBA" "${PG_HBA}.backup"

    # Ensure md5 authentication for local connections
    if ! grep -q "host.*netvisor.*netvisor.*127.0.0.1/32.*md5" "$PG_HBA"; then
        echo "host    netvisor        netvisor        127.0.0.1/32            md5" >> "$PG_HBA"
        systemctl restart postgresql
    fi

    print_success "PostgreSQL database configured"
}

# Create system user
create_user() {
    print_info "Creating netvisor system user..."

    if id "$DAEMON_USER" &>/dev/null; then
        print_info "User $DAEMON_USER already exists"
    else
        useradd -r -s /bin/false -d /nonexistent -c "NetVisor Service Account" $DAEMON_USER
        print_success "Created user: $DAEMON_USER"
    fi
}

# Build NetVisor
build_netvisor() {
    print_info "Building NetVisor from source..."

    cd "$SCRIPT_DIR"

    # Ensure Rust is in PATH
    export PATH="/usr/local/cargo/bin:$PATH"
    export RUSTUP_HOME=/usr/local/rustup
    export CARGO_HOME=/usr/local/cargo

    # Build backend (server and daemon)
    print_info "Building backend (this may take 10-15 minutes)..."
    cd backend
    cargo build --release --bin server
    cargo build --release --bin daemon
    cd ..

    # Build frontend UI
    print_info "Building frontend UI..."
    cd ui
    npm install
    npm run build
    cd ..

    print_success "Build completed successfully"
}

# Install NetVisor files
install_files() {
    print_info "Installing NetVisor files..."

    # Create directories
    mkdir -p "$INSTALL_DIR"/{bin,static}
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$DATA_DIR"
    mkdir -p "$LOG_DIR"

    # Install binaries
    cp backend/target/release/server "$INSTALL_DIR/bin/netvisor-server"
    cp backend/target/release/daemon "$INSTALL_DIR/bin/netvisor-daemon"
    chmod +x "$INSTALL_DIR/bin/"*

    # Install UI static files
    cp -r ui/build/* "$INSTALL_DIR/static/"

    # Set permissions
    chown -R $DAEMON_USER:$DAEMON_USER "$DATA_DIR"
    chown -R $DAEMON_USER:$DAEMON_USER "$LOG_DIR"
    chown -R root:root "$INSTALL_DIR"
    chown -R root:root "$CONFIG_DIR"

    print_success "Files installed to $INSTALL_DIR"
}

# Generate configuration
generate_config() {
    print_info "Generating configuration..."

    # Server configuration
    cat > "$CONFIG_DIR/server.env" << EOF
# NetVisor Server Configuration
NETVISOR_SERVER_PORT=60072
NETVISOR_LOG_LEVEL=info
NETVISOR_DATABASE_URL=postgresql://netvisor:${DB_PASSWORD}@localhost:5432/netvisor
NETVISOR_WEB_EXTERNAL_PATH=$INSTALL_DIR/static
NETVISOR_INTEGRATED_DAEMON_URL=http://127.0.0.1:60073
NETVISOR_USE_SECURE_SESSION_COOKIES=false
NETVISOR_DISABLE_REGISTRATION=false
EOF

    # Daemon configuration
    cat > "$CONFIG_DIR/daemon.env" << EOF
# NetVisor Daemon Configuration
NETVISOR_SERVER_TARGET=http://127.0.0.1
NETVISOR_SERVER_PORT=60072
NETVISOR_DAEMON_PORT=60073
NETVISOR_BIND_ADDRESS=0.0.0.0
NETVISOR_NAME=netvisor-daemon
NETVISOR_LOG_LEVEL=info
NETVISOR_HEARTBEAT_INTERVAL=30
EOF

    chmod 600 "$CONFIG_DIR"/*.env

    print_success "Configuration files created in $CONFIG_DIR"
}

# Install systemd services
install_services() {
    print_info "Installing systemd services..."

    # Server service
    cat > /etc/systemd/system/netvisor-server.service << EOF
[Unit]
Description=NetVisor Server
Documentation=https://github.com/mayanayza/netvisor
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=root
EnvironmentFile=$CONFIG_DIR/server.env
ExecStart=$INSTALL_DIR/bin/netvisor-server
Restart=on-failure
RestartSec=10
StandardOutput=append:$LOG_DIR/server.log
StandardError=append:$LOG_DIR/server-error.log

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$DATA_DIR $LOG_DIR
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF

    # Daemon service
    cat > /etc/systemd/system/netvisor-daemon.service << EOF
[Unit]
Description=NetVisor Network Discovery Daemon
Documentation=https://github.com/mayanayza/netvisor
After=network.target netvisor-server.service
Requires=netvisor-server.service

[Service]
Type=simple
User=root
EnvironmentFile=$CONFIG_DIR/daemon.env
ExecStart=$INSTALL_DIR/bin/netvisor-daemon
Restart=on-failure
RestartSec=10
StandardOutput=append:$LOG_DIR/daemon.log
StandardError=append:$LOG_DIR/daemon-error.log

# Daemon needs network access for scanning
# Note: Requires elevated privileges for raw socket access
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_RAW CAP_NET_ADMIN

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    systemctl daemon-reload

    print_success "Systemd services installed"
}

# Main installation function
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          NetVisor Ubuntu Native Installation              ║"
    echo "║                    Version $VERSION                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    check_root
    check_ubuntu
    check_requirements

    # Generate random database password
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

    print_info "Starting installation..."
    echo ""

    # Installation steps
    install_dependencies
    install_rust
    install_nodejs
    create_user
    setup_database
    build_netvisor
    install_files
    generate_config
    install_services

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    print_success "NetVisor has been installed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Start the services:"
    echo "     sudo systemctl start netvisor-server"
    echo "     sudo systemctl start netvisor-daemon"
    echo ""
    echo "  2. Enable services to start on boot:"
    echo "     sudo systemctl enable netvisor-server"
    echo "     sudo systemctl enable netvisor-daemon"
    echo ""
    echo "  3. Check service status:"
    echo "     sudo systemctl status netvisor-server"
    echo "     sudo systemctl status netvisor-daemon"
    echo ""
    echo "  4. Access the web interface:"
    echo "     http://$(hostname -I | awk '{print $1}'):60072"
    echo "     or http://localhost:60072"
    echo ""
    print_info "Configuration files:"
    echo "  - Server: $CONFIG_DIR/server.env"
    echo "  - Daemon: $CONFIG_DIR/daemon.env"
    echo ""
    print_info "Log files:"
    echo "  - Server: $LOG_DIR/server.log"
    echo "  - Daemon: $LOG_DIR/daemon.log"
    echo ""
    print_warning "Database password has been saved to: $CONFIG_DIR/server.env"
    echo ""
    print_info "For more information, visit: https://github.com/mayanayza/netvisor"
    echo ""
}

# Run main function
main "$@"
