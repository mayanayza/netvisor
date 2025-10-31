# NetVisor

**Automatically discover and visually document network topology.**

NetVisor scans your network, identifies hosts and services, and generates an interactive visualization showing how everything connects, letting you easily create and maintain network documentation.

![License](https://img.shields.io/github/license/mayanayza/netvisor)![GitHub release](https://img.shields.io/github/v/release/mayanayza/netvisor)
![Daemon](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/daemon-ci.yml?label=daemon-ci)![Server](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/server-ci.yml?label=server-ci)![UI](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/ui-ci.yml?label=ui-ci)
[![Discord](https://img.shields.io/discord/1432872786828726392?logo=discord&label=discord&labelColor=white&color=7289da)](https://discord.gg/b7ffQr8AcZ)

<p align="center">
  <img src="./media/example_visualization.jpeg" width="1200" alt="Example Visualization">
</p>

## Table of Contents

- [Architecture](#architecture)
- [Installation](#installation)
- [Discovery](#discovery)
  - [Docker](#docker)
  - [Network Scanning](#network-scanning)
- [Network Organization](#network-organization)
  - [Consolidating Hosts](#consolidating-hosts)
  - [Subnets](#subnets)
  - [Groups](#groups)
- [Topology Visualization](#topology-visualization)
- [Configuration](#configuration)
  - [Daemon Configuration](#daemon-configuration)
  - [Server Configuration](#server-configuration)
- [Troubleshooting](#troubleshooting)
- [Uninstall Daemon](#uninstall-daemon)
- [FAQ](#faq)
  - [Where does NetVisor store my data?](#where-does-netvisor-store-my-data)
  - [What services can NetVisor discover?](#what-services-can-netvisor-discover)
  - [Are VLANs supported?](#are-vlans-supported)
  - [Is IPv6 Supported?](#is-ipv6-supported)

## Architecture

NetVisor consists of two components:

**Server**: Central hub that stores network data, generates topology visualizations, and serves the web UI. Runs as a Docker container with a PostgreSql database.

**Daemon**: Lightweight agent that performs network scanning and reports back to the server. Can run on one or multiple hosts to map different network segments.

The server-daemon architecture allows you to scan networks from multiple vantage points, essential for mapping VLANs and complex network topologies.

## Installation

Refer to [configuration](#configuration) for more setup options.

### 0. Install Requirements

#### Daemon
- **Linux**: Docker with host networking support, OR binary installation
- **Mac**: Binary installation only (Docker Desktop does not support host networking)

#### Server (Docker - Recommended)
- Docker
- Docker Compose

#### Server (Building from source)
- Rust 1.90 or later
- Node.js 20 or later

### 1. Start the Server

```bash
curl -O https://raw.githubusercontent.com/mayanayza/netvisor/refs/heads/main/docker-compose.yml && docker compose up -d
```

or, run the contents of `docker-compose.yml`

The server collects data from the daemon(s) and generates the topology visualization. The server can support multiple daemon instances in case you want to collect data from the perspective of multiple hosts on your network (ie - mapping out vlans).

**Note**: the daemon container assumes your default docker bridge network is 172.17.0.1. If this is not the case, update the address in the NETVISOR_INTEGRATED_DAEMON_URL env var.

### 2. Load the UI

Navigate to `http://<your-ip>:60072` (or whichever port you configured) to load the UI.

On first load, the UI will automatically:
- Create your user account
- Initialize a default network
- Start the integrated daemon (if running the full docker-compose stack)

The integrated daemon will automatically begin reporting to your network once initialization is complete.

### 3. Deploy Additional Daemons (Optional)

To scan from multiple network vantage points (e.g., different VLANs or remote locations):

1. Navigate to the **Discover** tab in the UI
2. Click **"Create New Daemon"**
3. Copy the generated docker-compose or installation command
4. Run it on your target host

Each daemon will automatically connect to your server and begin reporting discovered hosts and services.

You can also do this at any point after running discovery with the integrated daemon.

## Discovery

### Docker

If the host running the daemon is also running Docker, the daemon automatically detects containerized services by connecting to the Docker socket. This provides enhanced service discovery including:
- Container names and metadata
- Service-to-container relationships
- Internal Docker networks
- Container ports and exposed services

**Important**: The daemon connects to the Docker socket at `/var/run/docker.sock`. To ensure it has access to this, uncomment the line in `docker-compose.daemon.yml` that mounts the Docker socket to the container. If you are running the binary directly, you can ignore this.

### Network Scanning

Once you have a daemon up and running, it will be available in the Discover tab. Click the Discovery button to start network scanning.

<p align="center">
  <img src="./media/discovery.png" width="400" alt="Run Discovery">
</p>

The NetVisor Daemon discovers hosts on your network by scanning all IPv4 addresses on subnets that the host it runs on has a network interface with. For each IP on the network, the daemon:

- **Detects services**: Uses rule based pattern matching to recognize running services using open ports, HTTP endpoints responses, and other data from the host.
- **Maps interfaces**: Detects host network interfaces and their subnet membership

Discovery creates hosts with their interfaces, services, and subnet relationships.

Discovery can take 5-10+ minutes depending on how many subnets the daemon's host is connected and the network mask for those subnets, as it needs to scan every IP address on the subnet.

## Network Organization

### Managing Virtualization & Containers

Hosts with Proxmox and Docker services will have an additional virtualization tab allowing you to manage hosts / services that they manage as VMs / containers. This will change how these hosts / services are represented in the visualization.

<p align="center">
  <img src="./media/virtualization_management.png" width="800" alt="Virtualization Management">
</p>


### Consolidating Hosts

The discovery process does its best to merge duplicate hosts, but this isn't always possible. You can consolidate hosts that actually represent multiple interfaces or services on the same host using the Consolidate feature. This migrates all ports, interfaces, and services to a single host record.

<p align="center">
  <img src="./media/consolidate_host.png" width="400" alt="Consolidate Host">
</p>

### Subnets

Subnets organize your network into logical segments of hosts. Subnets are automatically created during discovery.

<p align="center">
  <img src="./media/subnet.png" width="400" alt="Subnet">
</p>

**Infrastructure Services**: The discovery process identifies hosts providing infrastructure services (DNS, gateway, reverse proxy) on a subnet and flags them. You can edit this in the subnet if needed.

**Organizational Subnets**: Subnets with 0.0.0.0/0 CIDR can be used to organize external resources (like internet services or remote hosts) that aren't on your local network but you want to include in your topology.

### Groups

Groups let you visualize logical connections between services, such as a web app talking to its database, or representing network paths between different parts of your infrastructure. You can also create groups to represent the relatinoship between hosts and any virtualized services (ie Docker, K8s, LXC). You'll need to create groups manually.

<p align="center">
  <img src="./media/group.png" width="400" alt="Group">
</p>

## Topology Visualization

The topology auto-generates from your hosts, subnets, and service groups, creating living documentation that updates as your network changes.

You can customize the visualization:
- **Anchor points**: Click edges to change where they connect to nodes
- **Subnet sizing**: Drag subnet boundaries to resize
- **Layout**: Drag hosts and subnets to organize your topology

## Configuration

Both the server and daemon support multiple configuration methods with the following priority order (highest to lowest):

1. **Command-line arguments** (highest priority)
2. **Environment variables**
3. **Configuration file** (daemon only)
4. **Default values** (lowest priority)

### Daemon Configuration

| Parameter | CLI Flag | Environment Variable | Config File Key | Default | Description |
|-----------|----------|---------------------|-----------------|---------|-------------|
| Server Target | `--server-target` | `NETVISOR_SERVER_TARGET` | `server_target` | `None` | IP address or hostname of the NetVisor server (required) |
| Server Port | `--server-port` | `NETVISOR_SERVER_PORT` | `server_port` | `60072` | Port the NetVisor server is listening on |
| Daemon Port | `--daemon-port` or `-p` | `NETVISOR_DAEMON_PORT` | `daemon_port` | `60073` | Port for the daemon to listen on |
| Bind Address | `--bind-address` | `NETVISOR_BIND_ADDRESS` | `bind_address` | `0.0.0.0` | IP address to bind the daemon to |
| Daemon Name | `--name` | `NETVISOR_NAME` | `name` | `netvisor-daemon` | Human-readable name for this daemon instance |
| Log Level | `--log-level` | `NETVISOR_LOG_LEVEL` | `log_level` | `info` | Logging verbosity (`trace`, `debug`, `info`, `warn`, `error`) |
| Heartbeat Interval | `--heartbeat-interval` | `NETVISOR_HEARTBEAT_INTERVAL` | `heartbeat_interval` | `30` | Seconds between heartbeat updates to the server |
| Concurrent Scans | `--concurrent-scans` | `NETVISOR_CONCURRENT_SCANS` | `concurrent_scans` | `15` | Maximum number of hosts to scan in parallel during discovery |
| Network ID | `--network-id` | `NETVISOR_NETWORK_ID` | `network_id` | `None` | Network ID to report discoveries to (auto-assigned for integrated daemon) |
| API key | `--api-key` | `NETVISOR_DAEMON_API_KEY` | `daemon_api_key` | `None` | API key that daemon will use to authenticate with server (auto-assigned; UI will display notification if needed) |


#### Configuration File Location

The daemon automatically creates and maintains a configuration file at:
- **Linux**: `~/.config/netvisor/daemon/config.json`
- **macOS**: `~/Library/Application Support/com.netvisor.daemon/config.json`
- **Windows**: `%APPDATA%\netvisor\daemon\config.json`

The configuration file persists runtime state (daemon ID, host ID, last heartbeat) alongside your configured settings.

### Server Configuration

The server supports the following configuration options:

| Parameter | CLI Flag | Environment Variable | Default | Description |
|-----------|----------|---------------------|---------|-------------|
| Server Port | `--server-port` | `NETVISOR_SERVER_PORT` | `60072` | Port for the server to listen on |
| Log Level | `--log-level` | `NETVISOR_LOG_LEVEL` | `info` | Logging verbosity (`trace`, `debug`, `info`, `warn`, `error`) |
| Rust Log | `--rust-log` | `NETVISOR_RUST_LOG` | `""` | Low-level Rust framework logging |
| Database URL | `--database-url` | `NETVISOR_DATABASE_URL` | `postgresql://postgres:password@localhost:5432/netvisor` | PostgreSQL connection string |
| Use Secure Cookies | `--use-secure-session-cookies` | `NETVISOR_USE_SECURE_SESSION_COOKIES` | `false` | Set `true` when running behind HTTPS. Set `false` for HTTP/internal networks |

### UI Configuration

The UI supports the following configuration options for API connectivity:

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| Server Hostname | `PUBLIC_SERVER_HOSTNAME` | `default` | Hostname for API requests. Use `default` to automatically use the browser's hostname (recommended for most setups, including reverse proxies). Set to a specific hostname only when the API is on a different domain. |
| Server Port | `PUBLIC_SERVER_PORT` | `60072` | Port for API requests. Only used when `PUBLIC_SERVER_HOSTNAME` is set to a specific hostname (not `default`). Omit this variable when using a reverse proxy on standard ports. |

**Examples:**

- **Direct access (development)**: Use default settings
```env
  PUBLIC_SERVER_HOSTNAME=default
  PUBLIC_SERVER_PORT=60072
```

- **Reverse proxy (production)**: Use default hostname, omit port
```env
  PUBLIC_SERVER_HOSTNAME=default
  # PUBLIC_SERVER_PORT not needed
```

- **API on different domain**: Specify both hostname and port
```env
  PUBLIC_SERVER_HOSTNAME=api.example.com
  PUBLIC_SERVER_PORT=8080
```

**Note:** When `PUBLIC_SERVER_HOSTNAME=default`, the UI uses relative URLs that automatically inherit the protocol, hostname, and port from your browser's address bar. This works seamlessly with reverse proxies and different deployment configurations.

## Troubleshooting

### Error: CONCURRENT_SCANS is too high for this system

The CONCURRENT_SCANS env var controls concurrent network scan operations. If too high, the system running the daemon will run out of memory.

You can control this using the environment variable `NETVISOR_CONCURRENT_SCANS`.

- **Recommended ranges**:
  - Low-resource systems (Raspberry Pi): 5-10
  - Developer laptops: 15-20
  - Docker containers: 10-30 (depends on container memory limits)
  - Servers: 25-50

### Integrated Daemon Not Initializing

If the integrated daemon (included in docker-compose.yml) fails to initialize after loading the UI:

1. **Check daemon logs**: `docker logs netvisor-daemon`
2. **Check server logs**: `docker logs netvisor-server`
3. **Verify server can reach daemon**: Ensure the daemon's `NETVISOR_INTEGRATED_DAEMON_URL` environment variable is correctly set in the server service. For most setups, the default configuration ( `http://172.17.0.1:60073`) should work. If you're using a custom Docker network, or running in an environment like an LXC, you may need to adjust the gateway IP.
4. **Verify server is accessible**: The daemon must be able to reach the server. If using the default docker-compose, this should work automatically.

## Uninstall Daemon

#### Linux (Docker)

```bash
docker stop netvisor-daemon
docker rm netvisor-daemon
docker volume rm netvisor_daemon-config  # Optional: remove persisted config
```

#### Linux (Binary)

```bash
sudo rm /usr/local/bin/netvisor-daemon
rm -rf ~/.config/netvisor/daemon
```

#### Mac (Binary)

```bash
sudo rm /usr/local/bin/netvisor-daemon
rm -rf ~/Library/Application\ Support/com.netvisor.daemon
```

#### Windows (Binary)
```cmd
del %LOCALAPPDATA%\Programs\netvisor-daemon\netvisor-daemon.exe
rmdir /s %APPDATA%\netvisor\daemon
```

## FAQ

### Where does NetVisor store my data?

NetVisor stores all data locally in a SQLite database on your server. No data is sent to external services. Communication between daemon and server occurs over your local network.

### Are VLANs supported?

Yes, you can collect information from hosts on multiple VLANs by deploying multiple daemons:

1. Go to the **Discover** tab in the UI
2. Click **"Create New Daemon"** 
3. Deploy the generated daemon on a host connected to each VLAN you want to scan

You may need to use the [Consolidate](#consolidating-hosts) feature to merge hosts that appear on multiple VLANs with different IP addresses.

### Is IPv6 supported?

Not currently. Future plans to support IPv6 will focus on collecting a host's IPv6 address during discovery and/or allowing manual entry of it during editing. Scanning the entire IPv6 space of a discovered subnet will never be supported as it will take too long to do so.

### What services can NetVisor discover?

NetVisor automatically detects 50+ common services including:

**Media Servers**: Plex, Jellyfin, Emby  
**Home Automation**: Home Assistant, Philips Hue Bridge  
**Virtualization**: Proxmox, Docker, Kubernetes  
**Network Services**: Pi-hole, AdGuard Home, Unifi Controller, pfSense, OPNsense  
**Storage**: Synology, QNAP, TrueNAS, Nextcloud  
**Monitoring**: Grafana, Prometheus, Uptime Kuma  
**Reverse Proxies**: Nginx Proxy Manager, Traefik, Cloudflared  
...and many more

For a complete list, see the [service definitions](https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions).

If you are running a service which is on this list but it isn't detected, OR
If you are running a service which is not on this list and want it to be added - [open an issue](https://github.com/mayanayza/netvisor/issues/new)
