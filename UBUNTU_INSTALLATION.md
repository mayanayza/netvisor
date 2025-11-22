# NetVisor Ubuntu Native Installation Guide

This guide explains how to build and run NetVisor natively on Ubuntu without Docker.

## Table of Contents

- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Installation Methods](#installation-methods)
  - [Method 1: Full Installation (Recommended)](#method-1-full-installation-recommended)
  - [Method 2: Build Only](#method-2-build-only)
  - [Method 3: Manual Installation](#method-3-manual-installation)
- [Configuration](#configuration)
- [Service Management](#service-management)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

---

## Quick Start

**One-command installation:**

```bash
sudo ./install-ubuntu.sh
```

This will:
- Install all dependencies (Rust, Node.js, PostgreSQL)
- Build NetVisor from source
- Set up the database
- Install systemd services
- Configure everything automatically

After installation:
```bash
sudo systemctl start netvisor-server
sudo systemctl start netvisor-daemon
```

Access NetVisor at: `http://localhost:60072`

---

## Requirements

### Minimum System Requirements

- **OS**: Ubuntu 20.04 LTS or newer (also works on Debian-based distros)
- **RAM**: 2GB minimum (4GB recommended)
- **Disk**: 5GB free space
- **CPU**: Any modern x86_64 or ARM64 processor

### Software Dependencies

The installation script will install these automatically:

- **Rust** 1.90+ (toolchain for building backend)
- **Node.js** 20+ (for building UI)
- **PostgreSQL** 14+ (database)
- **Build tools**: gcc, make, pkg-config, libssl-dev

---

## Installation Methods

### Method 1: Full Installation (Recommended)

This method installs NetVisor as a system service with automatic startup.

#### Step 1: Clone the repository

```bash
git clone https://github.com/mayanayza/netvisor.git
cd netvisor
```

#### Step 2: Make installation script executable

```bash
chmod +x install-ubuntu.sh
```

#### Step 3: Run the installer

```bash
sudo ./install-ubuntu.sh
```

The installer will:
1. Check system requirements
2. Install dependencies (Rust, Node.js, PostgreSQL)
3. Build NetVisor from source (takes 10-15 minutes)
4. Create system user `netvisor`
5. Set up PostgreSQL database with a random password
6. Install binaries to `/opt/netvisor`
7. Create systemd services
8. Generate configuration files in `/etc/netvisor`

#### Step 4: Start the services

```bash
sudo systemctl start netvisor-server
sudo systemctl start netvisor-daemon
```

#### Step 5: Enable auto-start on boot

```bash
sudo systemctl enable netvisor-server
sudo systemctl enable netvisor-daemon
```

#### Step 6: Access the web interface

Open your browser and navigate to:
```
http://localhost:60072
```

Or use your server's IP address:
```
http://<your-server-ip>:60072
```

---

### Method 2: Build Only

If you want to build NetVisor without installing it as a service (for development):

#### Prerequisites

Install dependencies manually:

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install build tools
sudo apt-get install -y build-essential pkg-config libssl-dev postgresql
```

#### Build

```bash
chmod +x build-ubuntu.sh
./build-ubuntu.sh
```

This builds:
- Server binary: `backend/target/release/server`
- Daemon binary: `backend/target/release/daemon`
- UI static files: `ui/build/`

#### Run in Development Mode

**Terminal 1 - Database:**
```bash
make setup-db
```

**Terminal 2 - Server:**
```bash
cd backend
export DATABASE_URL='postgresql://postgres:password@localhost:5432/netvisor'
cargo run --bin server
```

**Terminal 3 - Daemon:**
```bash
cd backend
cargo run --bin daemon -- --server-target http://127.0.0.1 --server-port 60072
```

Access at `http://localhost:60072`

---

### Method 3: Manual Installation

For advanced users who want full control over the installation process.

#### 1. Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
    curl wget git build-essential pkg-config \
    libssl-dev postgresql postgresql-contrib
```

#### 2. Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

#### 3. Install Node.js 20

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 4. Set Up PostgreSQL

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -u postgres psql << EOF
CREATE USER netvisor WITH PASSWORD 'your-secure-password';
CREATE DATABASE netvisor OWNER netvisor;
GRANT ALL PRIVILEGES ON DATABASE netvisor TO netvisor;
EOF
```

#### 5. Build NetVisor

```bash
# Build backend
cd backend
cargo build --release --bin server
cargo build --release --bin daemon
cd ..

# Build frontend
cd ui
npm install
npm run build
cd ..
```

#### 6. Install Binaries

```bash
sudo mkdir -p /opt/netvisor/{bin,static}
sudo cp backend/target/release/server /opt/netvisor/bin/netvisor-server
sudo cp backend/target/release/daemon /opt/netvisor/bin/netvisor-daemon
sudo cp -r ui/build/* /opt/netvisor/static/
sudo chmod +x /opt/netvisor/bin/*
```

#### 7. Create Configuration

```bash
sudo mkdir -p /etc/netvisor

sudo tee /etc/netvisor/server.env << EOF
NETVISOR_SERVER_PORT=60072
NETVISOR_LOG_LEVEL=info
NETVISOR_DATABASE_URL=postgresql://netvisor:your-secure-password@localhost:5432/netvisor
NETVISOR_WEB_EXTERNAL_PATH=/opt/netvisor/static
NETVISOR_INTEGRATED_DAEMON_URL=http://127.0.0.1:60073
EOF

sudo tee /etc/netvisor/daemon.env << EOF
NETVISOR_SERVER_TARGET=http://127.0.0.1
NETVISOR_SERVER_PORT=60072
NETVISOR_DAEMON_PORT=60073
NETVISOR_BIND_ADDRESS=0.0.0.0
NETVISOR_NAME=netvisor-daemon
NETVISOR_LOG_LEVEL=info
EOF

sudo chmod 600 /etc/netvisor/*.env
```

#### 8. Create Systemd Services

**Server service:**
```bash
sudo tee /etc/systemd/system/netvisor-server.service << EOF
[Unit]
Description=NetVisor Server
After=network.target postgresql.service

[Service]
Type=simple
User=root
EnvironmentFile=/etc/netvisor/server.env
ExecStart=/opt/netvisor/bin/netvisor-server
Restart=on-failure
StandardOutput=append:/var/log/netvisor/server.log
StandardError=append:/var/log/netvisor/server-error.log

[Install]
WantedBy=multi-user.target
EOF
```

**Daemon service:**
```bash
sudo tee /etc/systemd/system/netvisor-daemon.service << EOF
[Unit]
Description=NetVisor Network Discovery Daemon
After=network.target netvisor-server.service

[Service]
Type=simple
User=root
EnvironmentFile=/etc/netvisor/daemon.env
ExecStart=/opt/netvisor/bin/netvisor-daemon
Restart=on-failure
StandardOutput=append:/var/log/netvisor/daemon.log
StandardError=append:/var/log/netvisor/daemon-error.log
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_RAW CAP_NET_ADMIN

[Install]
WantedBy=multi-user.target
EOF
```

#### 9. Start Services

```bash
sudo mkdir -p /var/log/netvisor
sudo systemctl daemon-reload
sudo systemctl start netvisor-server
sudo systemctl start netvisor-daemon
sudo systemctl enable netvisor-server
sudo systemctl enable netvisor-daemon
```

---

## Configuration

### Configuration Files

After installation, configuration files are located in `/etc/netvisor/`:

- **server.env**: Server configuration
- **daemon.env**: Daemon configuration

### Important Settings

#### Server Configuration (`/etc/netvisor/server.env`)

```bash
# Port for web UI and API
NETVISOR_SERVER_PORT=60072

# Log level (trace, debug, info, warn, error)
NETVISOR_LOG_LEVEL=info

# Database connection
NETVISOR_DATABASE_URL=postgresql://netvisor:password@localhost:5432/netvisor

# Path to UI static files
NETVISOR_WEB_EXTERNAL_PATH=/opt/netvisor/static

# URL where daemon can be reached
NETVISOR_INTEGRATED_DAEMON_URL=http://127.0.0.1:60073

# Enable for HTTPS deployments
NETVISOR_USE_SECURE_SESSION_COOKIES=false

# Disable new user registration
NETVISOR_DISABLE_REGISTRATION=false
```

#### Daemon Configuration (`/etc/netvisor/daemon.env`)

```bash
# Server connection
NETVISOR_SERVER_TARGET=http://127.0.0.1
NETVISOR_SERVER_PORT=60072

# Daemon listening port
NETVISOR_DAEMON_PORT=60073
NETVISOR_BIND_ADDRESS=0.0.0.0

# Daemon name shown in UI
NETVISOR_NAME=netvisor-daemon

# Log level
NETVISOR_LOG_LEVEL=info

# Heartbeat interval (seconds)
NETVISOR_HEARTBEAT_INTERVAL=30
```

### Applying Configuration Changes

After modifying configuration files:

```bash
sudo systemctl restart netvisor-server
sudo systemctl restart netvisor-daemon
```

---

## Service Management

### Check Service Status

```bash
# Server status
sudo systemctl status netvisor-server

# Daemon status
sudo systemctl status netvisor-daemon
```

### Start/Stop Services

```bash
# Start
sudo systemctl start netvisor-server
sudo systemctl start netvisor-daemon

# Stop
sudo systemctl stop netvisor-server
sudo systemctl stop netvisor-daemon

# Restart
sudo systemctl restart netvisor-server
sudo systemctl restart netvisor-daemon
```

### Enable/Disable Auto-Start

```bash
# Enable (start on boot)
sudo systemctl enable netvisor-server
sudo systemctl enable netvisor-daemon

# Disable
sudo systemctl disable netvisor-server
sudo systemctl disable netvisor-daemon
```

### View Logs

```bash
# Real-time server logs
sudo tail -f /var/log/netvisor/server.log

# Real-time daemon logs
sudo tail -f /var/log/netvisor/daemon.log

# Error logs
sudo tail -f /var/log/netvisor/server-error.log
sudo tail -f /var/log/netvisor/daemon-error.log

# Using journalctl
sudo journalctl -u netvisor-server -f
sudo journalctl -u netvisor-daemon -f
```

---

## Troubleshooting

### Server Won't Start

**Check logs:**
```bash
sudo journalctl -u netvisor-server -n 50
sudo cat /var/log/netvisor/server-error.log
```

**Common issues:**

1. **Database connection failed**
   - Verify PostgreSQL is running: `sudo systemctl status postgresql`
   - Check database exists: `sudo -u postgres psql -l | grep netvisor`
   - Verify password in `/etc/netvisor/server.env`

2. **Port already in use**
   - Check what's using port 60072: `sudo lsof -i :60072`
   - Change port in `/etc/netvisor/server.env` and `/etc/netvisor/daemon.env`

3. **Permission denied**
   - Check file permissions: `ls -la /opt/netvisor/bin/`
   - Ensure binaries are executable: `sudo chmod +x /opt/netvisor/bin/*`

### Daemon Won't Start

**Check logs:**
```bash
sudo journalctl -u netvisor-daemon -n 50
```

**Common issues:**

1. **Cannot connect to server**
   - Ensure server is running first: `sudo systemctl status netvisor-server`
   - Check server URL in `/etc/netvisor/daemon.env`

2. **Permission denied for network scanning**
   - Daemon needs elevated privileges for raw socket access
   - Service runs as root with specific capabilities

### Web UI Not Loading

1. **Check server is running:**
   ```bash
   sudo systemctl status netvisor-server
   ```

2. **Test server is listening:**
   ```bash
   curl http://localhost:60072/api/health
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 60072/tcp
   ```

### Database Issues

**Reset database:**
```bash
sudo -u postgres psql << EOF
DROP DATABASE netvisor;
DROP USER netvisor;
CREATE USER netvisor WITH PASSWORD 'your-password';
CREATE DATABASE netvisor OWNER netvisor;
EOF

# Restart server to run migrations
sudo systemctl restart netvisor-server
```

### Build Errors

**Rust compilation errors:**
```bash
# Update Rust
rustup update stable

# Clean and rebuild
cd backend
cargo clean
cargo build --release
```

**Node.js/UI build errors:**
```bash
cd ui
rm -rf node_modules package-lock.json
npm install
npm run build
```

---

## Uninstallation

### Automated Uninstall

```bash
chmod +x uninstall-ubuntu.sh
sudo ./uninstall-ubuntu.sh
```

This removes:
- Systemd services
- Installed binaries
- Configuration files
- Data directory
- Log files
- System user

Optionally removes PostgreSQL database (asks during uninstall).

### Manual Uninstall

```bash
# Stop and remove services
sudo systemctl stop netvisor-server netvisor-daemon
sudo systemctl disable netvisor-server netvisor-daemon
sudo rm /etc/systemd/system/netvisor-*.service
sudo systemctl daemon-reload

# Remove files
sudo rm -rf /opt/netvisor
sudo rm -rf /etc/netvisor
sudo rm -rf /var/lib/netvisor
sudo rm -rf /var/log/netvisor

# Remove database (optional)
sudo -u postgres psql -c "DROP DATABASE netvisor;"
sudo -u postgres psql -c "DROP USER netvisor;"
```

---

## Performance Tuning

### For Large Networks

If scanning large networks (1000+ hosts):

```bash
# Increase file descriptor limits
echo "netvisor soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "netvisor hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Adjust PostgreSQL settings
sudo nano /etc/postgresql/*/main/postgresql.conf
# Increase max_connections to 200
# Increase shared_buffers to 256MB
```

### Reduce Resource Usage

For low-resource environments:

```bash
# In /etc/netvisor/daemon.env
NETVISOR_CONCURRENT_SCANS=5  # Reduce from default
```

---

## Security Recommendations

1. **Change default database password** in `/etc/netvisor/server.env`

2. **Enable HTTPS** using a reverse proxy (nginx/Apache):
   ```bash
   # In /etc/netvisor/server.env
   NETVISOR_USE_SECURE_SESSION_COOKIES=true
   ```

3. **Firewall configuration:**
   ```bash
   sudo ufw allow 60072/tcp  # Web UI
   sudo ufw deny 60073/tcp   # Daemon (internal only)
   ```

4. **Restrict database access:**
   - Edit `/etc/postgresql/*/main/pg_hba.conf`
   - Ensure netvisor user can only connect from localhost

---

## Getting Help

- **Documentation**: https://github.com/mayanayza/netvisor
- **Issues**: https://github.com/mayanayza/netvisor/issues
- **Discord**: https://discord.gg/b7ffQr8AcZ

---

## License

NetVisor is licensed under the terms specified in the [LICENSE](LICENSE) file.
