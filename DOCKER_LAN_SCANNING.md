# Docker LAN Scanning Guide

This guide explains how to configure NetVisor running in Docker to scan your entire Local Area Network (LAN).

## Quick Answer

**Good news!** The default `docker-compose.yml` is already configured to scan your LAN. The daemon uses `network_mode: host` which gives it direct access to your host's network interfaces.

However, you may need to adjust some settings depending on your network configuration.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Default Setup](#default-setup)
- [Verify LAN Scanning](#verify-lan-scanning)
- [Common Network Scenarios](#common-network-scenarios)
- [Troubleshooting](#troubleshooting)
- [Advanced Configurations](#advanced-configurations)

---

## How It Works

### Network Modes in Docker

**Default Bridge Mode** (won't work for LAN scanning):
- Container has its own isolated network
- Can only see other Docker containers
- Cannot scan your LAN

**Host Network Mode** (required for LAN scanning):
- Container shares the host's network stack
- Can see all host network interfaces
- Can scan the LAN just like a native application

### Required Configuration

For LAN scanning, the daemon needs:

1. ✅ **Host network mode** - `network_mode: host`
2. ✅ **Privileged mode** OR **Network capabilities** - For raw socket access
3. ✅ **Access to host interfaces** - Automatically provided by host mode

---

## Default Setup

The default `docker-compose.yml` already includes the correct configuration:

```yaml
daemon:
  image: mayanayza/netvisor-daemon:latest
  container_name: netvisor-daemon
  network_mode: host          # ← Gives access to host network
  privileged: true            # ← Allows network scanning
  restart: unless-stopped
  environment:
    NETVISOR_SERVER_TARGET: ${NETVISOR_SERVER_TARGET:-http://127.0.0.1}
    NETVISOR_SERVER_PORT: ${NETVISOR_SERVER_PORT:-60072}
    NETVISOR_DAEMON_PORT: ${NETVISOR_DAEMON_PORT:-60073}
  volumes:
    - daemon-config:/root/.config/daemon
    - /var/run/docker.sock:/var/run/docker.sock:ro  # Optional: Docker discovery
```

**This configuration will automatically scan:**
- Your LAN subnet (e.g., 192.168.1.0/24)
- Any VLANs your host has interfaces on
- Docker bridge networks (if Docker socket is mounted)

---

## Verify LAN Scanning

### Step 1: Check Your Network Configuration

First, identify your LAN subnet:

```bash
# On your Docker host, run:
ip addr show

# Or simpler:
hostname -I
```

Example output:
```
192.168.1.100  # Your host IP
```

This means your LAN is likely `192.168.1.0/24`

### Step 2: Start NetVisor

```bash
docker compose up -d
```

### Step 3: Check Daemon Logs

```bash
docker logs netvisor-daemon
```

Look for lines like:
```
[INFO] Detected network interfaces:
[INFO]   - eth0: 192.168.1.100/24
[INFO] Will scan subnet: 192.168.1.0/24
```

### Step 4: Trigger a Discovery

1. Access NetVisor UI: `http://localhost:60072`
2. Register/login
3. Go to **Discover > Scheduled**
4. Click **"Run Discovery Now"**
5. Switch to **Discover > Sessions** to watch progress

### Step 5: Verify Results

After 5-10 minutes, go to:
- **Manage > Hosts** - Should show devices on your LAN
- **Manage > Subnets** - Should show your LAN subnet (e.g., 192.168.1.0/24)
- **Topology** - Click reload to visualize your network

---

## Common Network Scenarios

### Scenario 1: Home Network (Simple)

**Network:** `192.168.1.0/24`
**Router:** `192.168.1.1`
**Host IP:** `192.168.1.50`

**Configuration:** Use default `docker-compose.yml` - no changes needed!

**Expected Discovery:**
- Your router (192.168.1.1)
- All devices on 192.168.1.x
- Services running on those devices

---

### Scenario 2: Multiple Subnets / VLANs

**Network Setup:**
- LAN 1: `192.168.1.0/24` (Main network)
- LAN 2: `192.168.2.0/24` (IoT devices)
- LAN 3: `10.0.0.0/24` (Servers)

**If your Docker host has interfaces on all subnets:**

The daemon will automatically detect and scan all of them!

**If your Docker host only has interface on one subnet:**

You have two options:

**Option A: Deploy additional daemons** (Recommended)

Deploy a daemon on each subnet:

1. In NetVisor UI, go to **Manage > Daemons**
2. Click **"Create Daemon"**
3. Select the network
4. Copy the docker-compose command
5. Run it on a host in the other subnet

**Option B: Configure routing and scan remotely**

If your host can route to other subnets:

1. In UI, go to **Manage > Subnets**
2. Click **"Create Subnet"**
3. Add the remote subnet (e.g., `192.168.2.0/24`)
4. In **Discover > Scheduled**, create a scan with that subnet

⚠️ **Note:** Without a local interface, the daemon cannot collect MAC addresses or hostnames.

---

### Scenario 3: Docker Host Behind Router/NAT

**Network Setup:**
```
Internet → Router (192.168.1.1) → LAN (192.168.1.0/24)
                                  └─ Docker Host (192.168.1.100)
```

**Configuration:** Default works perfectly!

The daemon will scan all devices on `192.168.1.0/24` including:
- The router itself (192.168.1.1)
- Other computers
- Phones, smart devices, etc.

---

### Scenario 4: Custom Bridge Network

If you want the server on a custom Docker network but daemon scanning LAN:

```yaml
services:
  daemon:
    image: mayanayza/netvisor-daemon:latest
    network_mode: host              # Must use host mode for LAN scanning
    privileged: true
    environment:
      NETVISOR_SERVER_TARGET: ${NETVISOR_SERVER_TARGET:-http://127.0.0.1}

  server:
    image: mayanayza/netvisor-server:latest
    networks:                       # Can use custom network
      - netvisor
    ports:
      - "60072:60072"
    environment:
      NETVISOR_INTEGRATED_DAEMON_URL: http://172.17.0.1:60073

networks:
  netvisor:
    driver: bridge
```

**Important:** When daemon uses `network_mode: host`:
- It cannot use `networks:` directive
- Server must be reachable at a host IP
- Default bridge gateway is usually `172.17.0.1`

---

## Troubleshooting

### Issue 1: Only Seeing Docker Networks, Not LAN

**Symptoms:**
- Daemon scans successfully
- Only sees `172.17.0.0/16` or `172.31.0.0/16`
- Missing your LAN devices

**Cause:** Daemon not using host network mode

**Solution:**

Check your docker-compose.yml:

```yaml
daemon:
  network_mode: host  # ← This must be present!
```

Restart:
```bash
docker compose down
docker compose up -d
```

---

### Issue 2: "Permission Denied" or "Operation Not Permitted"

**Symptoms:**
```
[ERROR] Failed to create raw socket: Operation not permitted
```

**Cause:** Insufficient privileges for network scanning

**Solution 1:** Use privileged mode (current default)
```yaml
daemon:
  privileged: true
```

**Solution 2:** Use specific capabilities (more secure)
```yaml
daemon:
  cap_add:
    - NET_RAW
    - NET_ADMIN
  # Remove privileged: true
```

---

### Issue 3: Daemon Can't Connect to Server

**Symptoms:**
```
[ERROR] Failed to register with server: Connection refused
```

**Cause:** When daemon uses `network_mode: host`, it needs correct server URL

**Solution:**

Update server target in docker-compose.yml or .env:

```yaml
# If server is in Docker:
NETVISOR_SERVER_TARGET: http://172.17.0.1

# If server is on host:
NETVISOR_SERVER_TARGET: http://127.0.0.1

# If server is on different machine:
NETVISOR_SERVER_TARGET: http://192.168.1.50
```

Also update server's daemon URL:
```yaml
# Server needs to reach daemon at host network
NETVISOR_INTEGRATED_DAEMON_URL: http://127.0.0.1:60073
# Or
NETVISOR_INTEGRATED_DAEMON_URL: http://172.17.0.1:60073
```

---

### Issue 4: Not Scanning Entire LAN Subnet

**Symptoms:**
- Some devices discovered
- Missing many known devices

**Possible Causes:**

1. **Firewall blocking:** Devices may have firewalls blocking port scans

2. **Wrong subnet mask:** Daemon detected wrong CIDR

   Check daemon logs for detected subnets:
   ```bash
   docker logs netvisor-daemon | grep "subnet"
   ```

   If wrong, manually add correct subnet in UI:
   - **Manage > Subnets > Create Subnet**
   - Enter correct CIDR (e.g., `192.168.1.0/24`)
   - Run discovery with that subnet

3. **Scan timeout:** Large networks take time

   Increase timeout or reduce concurrent scans:
   ```yaml
   daemon:
     environment:
       NETVISOR_CONCURRENT_SCANS: 10  # Reduce from default
   ```

---

### Issue 5: Daemon Running But Not Showing in UI

**Check daemon is registered:**

```bash
docker logs netvisor-daemon | grep -i "register"
```

Should see:
```
[INFO] Successfully registered with server
[INFO] Daemon ID: abc-123-def
```

If not:
1. Check server is running: `docker ps | grep netvisor-server`
2. Check server logs: `docker logs netvisor-server`
3. Verify network connectivity from daemon to server
4. Check API key is not expired (if using external daemon)

---

## Advanced Configurations

### Configuration 1: Scan Specific Subnets Only

If your host has many interfaces but you only want to scan specific subnets:

1. Let daemon start normally (it will detect all interfaces)
2. In UI, go to **Discover > Scheduled**
3. Edit or create a scheduled discovery
4. Select **"Network Scan"** type
5. Choose only the subnets you want to scan
6. Save and run

### Configuration 2: Exclude Docker Networks

If you want to scan LAN but NOT Docker bridge networks:

1. In UI, go to **Manage > Subnets**
2. Find Docker subnets (usually `172.17.0.0/16` or `172.31.0.0/16`)
3. Delete them or mark them differently
4. In **Discover > Scheduled**, only select your LAN subnets

### Configuration 3: Optimize for Large LANs

For networks with 500+ devices:

```yaml
daemon:
  environment:
    NETVISOR_CONCURRENT_SCANS: 20    # Scan more hosts in parallel
    NETVISOR_LOG_LEVEL: warn         # Reduce log verbosity
  deploy:
    resources:
      limits:
        memory: 2G                    # Increase memory limit
        cpus: '2'                     # Use more CPU
```

### Configuration 4: Multiple Daemons for Different VLANs

If you have multiple VLANs:

**docker-compose.vlan1.yml:**
```yaml
services:
  daemon-vlan1:
    image: mayanayza/netvisor-daemon:latest
    container_name: netvisor-daemon-vlan1
    network_mode: host
    privileged: true
    environment:
      NETVISOR_SERVER_TARGET: http://192.168.1.10
      NETVISOR_NAME: daemon-vlan1
      NETVISOR_DAEMON_PORT: 60073
      NETVISOR_NETWORK_ID: ${NETWORK_ID}
      NETVISOR_DAEMON_API_KEY: ${API_KEY}
```

**docker-compose.vlan2.yml** (on different host with VLAN 2 access):
```yaml
services:
  daemon-vlan2:
    image: mayanayza/netvisor-daemon:latest
    container_name: netvisor-daemon-vlan2
    network_mode: host
    privileged: true
    environment:
      NETVISOR_SERVER_TARGET: http://192.168.1.10
      NETVISOR_NAME: daemon-vlan2
      NETVISOR_DAEMON_PORT: 60073  # Can use same port on different host
      NETVISOR_NETWORK_ID: ${NETWORK_ID}
      NETVISOR_DAEMON_API_KEY: ${API_KEY}
```

---

## Network Discovery Best Practices

### 1. Understand What Will Be Scanned

By default, the daemon scans:
- ✅ All subnets the host has direct network interfaces on
- ✅ Docker bridge networks (if socket mounted)
- ❌ Remote subnets (unless you add them manually or deploy daemon there)

### 2. Initial Discovery Takes Time

- **Small network (< 50 devices):** 5-10 minutes
- **Medium network (50-200 devices):** 10-30 minutes
- **Large network (200+ devices):** 30-60+ minutes

Watch progress in **Discover > Sessions**

### 3. Schedule Regular Scans

After initial discovery:
1. Go to **Discover > Scheduled**
2. Set up recurring scans (daily/weekly)
3. NetVisor will automatically detect new devices and changes

### 4. Review Discovered Devices

After first scan:
1. Check **Manage > Hosts** - Verify expected devices found
2. Check **Manage > Services** - Review detected services
3. Check **Manage > Subnets** - Confirm correct network detection
4. Check **Topology** - Visualize your network

---

## Security Considerations

### Running Privileged Daemon

The daemon needs `privileged: true` or `CAP_NET_RAW + CAP_NET_ADMIN` for:
- Raw socket access (required for network scanning)
- ARP table access (for MAC address discovery)
- Interface enumeration

**Security recommendations:**

1. **Use specific capabilities instead of privileged** (more secure):
   ```yaml
   daemon:
     cap_add:
       - NET_RAW
       - NET_ADMIN
     # Remove: privileged: true
   ```

2. **Limit network access:**
   - Run on isolated management network if possible
   - Use firewall rules to restrict daemon access

3. **Keep updated:**
   ```bash
   docker compose pull
   docker compose up -d
   ```

---

## Example: Complete LAN Scanning Setup

Here's a complete working example for a typical home/small business network:

**Network:**
- LAN: `192.168.1.0/24`
- Router: `192.168.1.1`
- Docker Host: `192.168.1.100`

**docker-compose.yml:**
```yaml
services:
  daemon:
    image: mayanayza/netvisor-daemon:latest
    container_name: netvisor-daemon
    network_mode: host
    privileged: true
    restart: unless-stopped
    environment:
      NETVISOR_SERVER_TARGET: http://127.0.0.1
      NETVISOR_SERVER_PORT: 60072
      NETVISOR_DAEMON_PORT: 60073
      NETVISOR_NAME: primary-daemon
      NETVISOR_LOG_LEVEL: info
    volumes:
      - daemon-config:/root/.config/daemon
      - /var/run/docker.sock:/var/run/docker.sock:ro

  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: netvisor
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-change-me-in-production}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    networks:
      - netvisor

  server:
    image: mayanayza/netvisor-server:latest
    ports:
      - "60072:60072"
    environment:
      NETVISOR_SERVER_PORT: 60072
      NETVISOR_DATABASE_URL: postgresql://postgres:${POSTGRES_PASSWORD:-change-me-in-production}@postgres:5432/netvisor
      NETVISOR_INTEGRATED_DAEMON_URL: http://172.17.0.1:60073
      NETVISOR_LOG_LEVEL: info
    depends_on:
      - postgres
    restart: unless-stopped
    networks:
      - netvisor

volumes:
  postgres_data:
  daemon-config:

networks:
  netvisor:
    driver: bridge
```

**Start it:**
```bash
docker compose up -d
```

**Access:**
```
http://192.168.1.100:60072
```

**What it will discover:**
- All devices on `192.168.1.0/24`
- All services running on those devices
- Docker containers on the host
- Network topology

---

## Summary

✅ **Default docker-compose.yml already supports LAN scanning** via `network_mode: host`

✅ **No additional configuration needed** for most home/small business networks

✅ **Daemon automatically detects and scans** all subnets the host is connected to

✅ **For multiple VLANs**, deploy additional daemons on hosts in those networks

⚠️ **Must use `network_mode: host`** - bridge mode cannot scan LAN

⚠️ **Requires privileged mode or capabilities** for raw socket access

---

## Need Help?

- **Check logs:** `docker logs netvisor-daemon`
- **Documentation:** [Main README](README.md)
- **Issues:** https://github.com/mayanayza/netvisor/issues
- **Discord:** https://discord.gg/b7ffQr8AcZ
