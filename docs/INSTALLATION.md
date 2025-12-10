# Installation Guide

This guide covers installing NetVisor on various platforms and deployment scenarios.

## Table of Contents

- [Requirements](#requirements)
- [Docker Installation (Recommended)](#docker-installation-recommended)
- [Building from Source](#building-from-source)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Additional Daemons](#additional-daemons)
- [Troubleshooting](#troubleshooting)
- [Uninstalling](#uninstalling)

## Requirements

### Server Requirements

**Docker Installation (Recommended)**
- Docker Engine 20.10 or later
- Docker Compose V2

**Building from Source**
- Rust 1.90 or later
- Node.js 20 or later
- PostgreSQL 17
- 4GB RAM minimum
- 20GB disk space

### Daemon Requirements

**Integrated Daemon** (included in default docker-compose):
- Docker with host networking support
- Runs on same host as server

**Additional Daemons** (optional, for multi-VLAN scanning):
- **Linux**: Docker with host networking OR standalone binary
- **macOS**: Standalone binary only (Docker Desktop lacks host networking)
- **Windows**: Standalone binary only (Docker Desktop lacks host networking)

## Docker Installation (Recommended)

This is the easiest way to get started with NetVisor.

### 1. Download the Docker Compose File

```bash
curl -O https://raw.githubusercontent.com/netvisor-io/netvisor/refs/heads/main/docker-compose.yml
```

### 2. Review Configuration

The default `docker-compose.yml` includes:
- NetVisor server on port 60072
- PostgreSQL database
- Integrated daemon for immediate network scanning

**Important**: The integrated daemon assumes your Docker bridge network is `172.17.0.1`. If your Docker bridge uses a different address, edit the `NETVISOR_INTEGRATED_DAEMON_URL` environment variable in the compose file.

### 3. Start NetVisor

```bash
docker compose up -d
```

### 4. Verify Installation

Check that services are running:

```bash
docker compose ps
```

You should see:
- `netvisor-server` - Running on port 60072
- `netvisor-postgres` - PostgreSQL database
- `netvisor-daemon` - Integrated daemon

### 5. Access the UI

Navigate to `http://<your-server-ip>:60072`

You'll see the registration page on first load.

## Building from Source

Refer to [contributing](../contributing.md) for details on getting your dev environment set up to build from source.

## Platform-Specific Instructions

### Proxmox LXC Container

You can use this [helper script](https://community-scripts.github.io/ProxmoxVE/scripts?id=netvisor) to create a NetVisor LXC on your Proxmox host.

### Unraid

NetVisor is available as an Unraid community app.

**Common Issues:**

If running NetVisor directly on a Proxmox host and encountering `could not create any Unix-domain sockets`, add this to both the PostgreSQL and NetVisor services in your docker-compose:

```yaml
security_opt:
  - apparmor:unconfined
```

If running in an LXC, you may need to change `NETVISOR_INTEGRATED_DAEMON_URL` to `172.31.0.1`.

See [issue #87](https://github.com/netvisor-io/netvisor/issues/87) for more details.

## Additional Daemons

To scan multiple VLANs or remote networks, deploy additional daemons.

### Creating a Daemon

1. Navigate to **Manage > Daemons** in the NetVisor UI
2. Click **"Create Daemon"**
3. Select the target network
4. Select Daemon mode
5. Click **"Generate Key"** to create an API key
6. Copy either the Docker Compose or binary installation command

**Manual Installation:**

Download the appropriate binary from the [releases page](https://github.com/netvisor-io/netvisor/releases/latest):

- Linux x86_64: `netvisor-daemon-linux-amd64`
- Linux ARM64: `netvisor-daemon-linux-arm64`
- macOS x86_64: `netvisor-daemon-darwin-amd64`
- macOS ARM64: `netvisor-daemon-darwin-arm64`
- Windows x86_64: `netvisor-daemon-windows-amd64.exe`

Make it executable (Linux/macOS):

```bash
chmod +x netvisor-daemon
sudo mv netvisor-daemon /usr/local/bin/
```

**Run the Daemon:**

```bash
netvisor-daemon \
  --server-url http://YOUR_SERVER_URL \
  --network-id YOUR_NETWORK_ID \
  --daemon-api-key YOUR_API_KEY
  --mode push
```

### Systemd Service (Linux)

For automatic startup, the install script offers to set up a systemd service.

**Manual systemd setup:**

1. Download the service file:

```bash
curl -o netvisor-daemon.service https://raw.githubusercontent.com/netvisor-io/netvisor/main/netvisor-daemon.service
```

2. Edit the service file with your configuration:

```bash
sudo nano netvisor-daemon.service
```

Update the `ExecStart` line with your parameters.

3. Install and enable:

```bash
sudo mv netvisor-daemon.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable netvisor-daemon
sudo systemctl start netvisor-daemon
```

4. Check status:

```bash
sudo systemctl status netvisor-daemon
sudo journalctl -u netvisor-daemon -f
```

## Troubleshooting

### Integrated Daemon Not Initializing

**Symptoms**: Daemon shows in UI but doesn't start discovery

**Diagnosis**:

```bash
# Check daemon logs
docker logs netvisor-daemon

# Check if daemon can reach server
docker exec netvisor-daemon curl http://netvisor-server:60072/api/health
```

**Solutions**:

1. **Verify bridge network**: Check your Docker bridge IP
   ```bash
   docker network inspect bridge | grep Gateway
   ```

2. **Update compose file**: If gateway isn't `172.17.0.1`, update `NETVISOR_INTEGRATED_DAEMON_URL`

3. **Check API key**: Ensure the integrated daemon has a valid API key in the database

### Discovery Fails with "CONCURRENT_SCANS too high"

**Symptoms**: Daemon crashes or runs out of memory during scans

**Solution**: Reduce concurrent scans in daemon configuration:

**Docker:**
```yaml
environment:
  - NETVISOR_CONCURRENT_SCANS=10  # Reduce from default
```

**Binary:**
```bash
netvisor-daemon --concurrent-scans 10 ...
```

See [CONFIGURATION.md](CONFIGURATION.md#concurrent-scans) for recommended values.

### "Too Many Open Files" Error

**Symptoms**: `Critical error scanning: Too many open files (os error 24)` in daemon logs

**Causes**: System file descriptor limit is too low for the configured concurrent scans.

**Solutions**:

1. **Reduce concurrent scans** (easiest):
   ```yaml
   environment:
     - NETVISOR_CONCURRENT_SCANS=10
   ```

2. **Increase system file descriptor limit**:
   ```bash
   # Check current limit
   ulimit -n

   # Increase temporarily
   ulimit -n 65535

   # Increase permanently (add to /etc/security/limits.conf)
   * soft nofile 65535
   * hard nofile 65535
   ```

3. **For Docker**: Add to your daemon container:
   ```yaml
   ulimits:
     nofile:
       soft: 65535
       hard: 65535
   ```

### Port Already in Use

**Symptoms**: Server fails to start with "address already in use"

**Solution**: Change the port mapping in docker-compose.yml:

```yaml
ports:
  - "8080:60072"  # Change 60072 to any available port
```

### Permission Denied Errors (Linux)

**Symptoms**: "Permission denied" when accessing Docker socket

**Solution**: Add user to docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Log out and back in for changes to take effect.

### Browser Shows "SSL Protocol Error"

**Symptoms**: Browser displays "ERR_SSL_PROTOCOL_ERROR" or "SSL protocol is too long" when accessing NetVisor

**Cause**: Attempting to access the HTTP server using HTTPS.

**Solution**: Use `http://` (not `https://`) to access NetVisor directly:
```
http://your-server:60072
```

If you need HTTPS, configure a reverse proxy (Traefik, Nginx, Caddy) in front of NetVisor to handle TLS termination.

### PostgreSQL "Could not create any Unix-domain sockets" (Proxmox)

**Symptoms**: PostgreSQL container fails to start on Proxmox host with socket creation error

**Cause**: AppArmor security policy blocking socket creation.

**Solution**: Add to both PostgreSQL and NetVisor services in docker-compose.yml:

```yaml
security_opt:
  - apparmor:unconfined
```

See [issue #87](https://github.com/netvisor-io/netvisor/issues/87) for details.

### Discovery Takes Extremely Long (Hours)

**Symptoms**: Network discovery takes 10+ hours to complete

**Causes**:
1. Large Docker bridge networks (e.g., /16) being fully scanned
2. Multiple large subnets selected for a single discovery

**Solutions**:

1. **Check selected subnets**: In your Network Scan discovery, verify you haven't selected large Docker bridge networks (like 172.17.0.0/16)

2. **Use Docker discovery separately**: Run Docker discovery to discover containers, rather than scanning Docker bridge networks via Network Scan

3. **Reduce subnet scope**: Only select subnets that contain hosts you want to discover

### Daemon Stops When Terminal Closes

**Symptoms**: Daemon runs in foreground and stops when SSH session ends

**Solution**: Install as a systemd service (see [Systemd Service](#systemd-service-linux) above), or run with a process manager like `screen` or `tmux`.

## Uninstalling

### Docker Installation

```bash
# Stop and remove containers
docker compose down

# Remove volumes (deletes all data)
docker compose down -v

# Remove images
docker rmi mayanayza/netvisor-server:latest
docker rmi mayanayza/netvisor-daemon:latest
```

### Standalone Daemon

**Linux/macOS:**

```bash
# Stop systemd service (if installed)
sudo systemctl stop netvisor-daemon
sudo systemctl disable netvisor-daemon
sudo rm /etc/systemd/system/netvisor-daemon.service

# Remove binary
sudo rm /usr/local/bin/netvisor-daemon

# Remove configuration
rm -rf ~/.config/netvisor/  # Linux
rm -rf ~/Library/Application\ Support/com.netvisor.daemon/  # macOS
```

**Windows:**

1. Stop the daemon process
2. Delete the executable
3. Remove configuration from `%APPDATA%\netvisor\daemon\`

---

**Next Steps**: See the [User Guide](USER_GUIDE.md) to learn how to use NetVisor's features.