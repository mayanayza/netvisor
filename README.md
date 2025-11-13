# NetVisor

**Automatically discover and visually document network infrastructure.**

NetVisor scans your network, identifies hosts and services, and generates an interactive visualization showing how everything connects, letting you easily create and maintain network documentation.<br>
<br>
![Docker Pulls](https://img.shields.io/docker/pulls/mayanayza/netvisor-server?style=for-the-badge&logo=docker)  ![Github Stars](https://img.shields.io/github/stars/mayanayza/netvisor?style=for-the-badge&logo=github
)
![License](https://img.shields.io/github/license/mayanayza/netvisor?style=for-the-badge)  ![GitHub release](https://img.shields.io/github/v/release/mayanayza/netvisor?style=for-the-badge)<br>
![Daemon](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/daemon-ci.yml?label=daemon-ci&style=for-the-badge)  ![Server](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/server-ci.yml?label=server-ci&style=for-the-badge)  ![UI](https://img.shields.io/github/actions/workflow/status/mayanayza/netvisor/ui-ci.yml?label=ui-ci&style=for-the-badge)<br>
[![Discord](https://img.shields.io/discord/1432872786828726392?logo=discord&label=discord&labelColor=white&color=7289da&style=for-the-badge)](https://discord.gg/b7ffQr8AcZ)

> 💡 **Prefer not to self-host, or want to use this for your business?** [Get early access](https://netvisor.io) to NetVisor Cloud
> 
<p align="center">
  <img src="./media/872shots_so.png" width="1200" alt="Example Visualization">
</p>

## Why NetVisor?

**The Problem**: Maintaining accurate network documentation is tedious. Networks evolve constantly—new services get deployed, IPs change, containers spin up and down—and documentation falls out of date before it's even complete.

**The Solution**: NetVisor automatically discovers your entire network infrastructure and generates living documentation that stays current with your network's reality.

### Key Features

**🔍 Automatic Discovery**
- Scans networks to identify all hosts and services
- Detects 50+ services including Plex, Home Assistant, Proxmox, Docker, Kubernetes, Pi-hole, and more
- Maps Docker containers and Proxmox VMs with their relationships
- Supports multiple VLANs through distributed scanning

**🗺️ Interactive Visualization**
- Auto-generates network topology diagrams showing how everything connects
- Visualizes subnets, hosts, services, and their relationships
- Customizable layouts with drag-and-drop editing
- Export diagrams as PNG for documentation or presentations

**📊 Network Organization**
- Group services by application architecture or function
- Track infrastructure dependencies and data flows
- Consolidate duplicate host entries
- Organize external resources (cloud services, remote hosts)

**🔄 Living Documentation**
- Schedule recurring discovery scans (daily/weekly/etc.)
- Real-time updates as your network changes
- Historical tracking of network evolution
- Self-hosted with full data privacy

### Perfect For

- **Home Lab Enthusiasts**: Document your ever-growing infrastructure
- **IT Professionals**: Maintain accurate network inventory without manual spreadsheets  
- **System Administrators**: Visualize complex multi-VLAN environments
- **DevOps Teams**: Map containerized services and their dependencies
- **MSPs**: Manage multiple client networks with separate environments

---

**Want hosted NetVisor without the setup?** Get early access to our upcoming cloud service at [netvisor.io](https://netvisor.io)

---

## Table of Contents

- [Architecture](#-architecture)
- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [User Interface](#-user-interface)
  - [Authentication](#authentication)
  - [Navigation Overview](#navigation-overview)
- [Discovery](#-discovery)
  - [Docker Discovery](#-docker-discovery)
  - [Network Scanning](#-network-scanning)
- [Network Organization](#-network-organization)
  - [Networks](#networks)
  - [Consolidating Hosts](#consolidating-hosts)
  - [Subnets](#subnets)
  - [Groups](#groups)
- [Topology Visualization](#️-topology-visualization)
  - [Customization Options](#customization-options)
  - [Export](#export)
- [Configuration](#️-configuration)
  - [Daemon Configuration](#daemon-configuration)
  - [Server Configuration](#server-configuration)
  - [UI Configuration](#ui-configuration)
- [Troubleshooting](#-troubleshooting)
- [Uninstall Daemon](#-uninstall-daemon)
- [FAQ](#-faq)

---

## 🏗️ Architecture

NetVisor consists of two components:

**Server**: Central hub that stores network data, generates topology visualizations, and serves the web UI. Runs as a Docker container with a PostgreSQL database.

**Daemon**: Lightweight agent that performs network scanning and reports back to the server. Can run on one or multiple hosts to map different network segments.

The server-daemon architecture allows you to scan networks from multiple vantage points, essential for mapping VLANs and complex network topologies. The server's default docker compose (see below) includes an integrated daemon to get you up and running more easily.

---

## 📦 Installation

Refer to [Configuration](#️-configuration) for more setup options.

### 0. ✅ Install Requirements

#### Server (Docker - Recommended)
- Docker
- Docker Compose

#### Server (Building from source)
- Rust 1.90 or later
- Node.js 20 or later

#### Running on Proxmox

You can use this [helper script](https://community-scripts.github.io/ProxmoxVE/scripts?id=netvisor) to create a NetVisor LXC on your Proxmox host.

#### Additional Daemons (Optional)
- **Linux**: Docker with host networking support, OR binary installation
- **Mac**: Binary installation only (Docker Desktop does not support host networking)


### 1. 🚀 Start the Server

**Note**: The default docker compose includes a daemon which assumes your default Docker bridge network is `172.17.0.1`. If this is not the case, update the address in the `NETVISOR_INTEGRATED_DAEMON_URL` environment variable. 

```bash
curl -O https://raw.githubusercontent.com/mayanayza/netvisor/refs/heads/main/docker-compose.yml && docker compose up -d
```

or, run the contents of [docker-compose.yml](https://github.com/mayanayza/netvisor/blob/main/docker-compose.yml)

### 2. 🌐 Load the UI

Navigate to `http://<your-ip>:60072` (or whichever port you configured) to access the NetVisor web interface.

### 3. 📡 Deploy Additional Daemons (Optional)

To scan from multiple network vantage points (e.g., different VLANs or remote locations):

1. Navigate to **Manage > Daemons** in the sidebar
2. Click **"Create Daemon"**
3. Copy the generated docker-compose or installation command
4. Run it on your target host

Each daemon will automatically connect to your server and begin reporting discovered hosts and services.

You can deploy additional daemons at any time after setting up your first network.

---

## 🚀 Getting Started

### First Time Setup

1. **Access the UI** at `http://<your-server-ip>:60072`

2. **Create your account**: On first load, you'll see the registration page
   - Enter an email
   - Enter a password (minimum 12 characters with uppercase, lowercase, number, and special character)
   - Click **Register** to create your account
   - Alternatively: NetVisor supports OIDC. Go to [OIDC Setup](#oidc-setup) for more details.

<p align="center">
  <img src="./media/registration.png" width="400" alt="Registration Screen">
</p>

3. **Automatic initialization**: After registration, NetVisor automatically:
   - Creates a default network called "My Network"
   - Starts the integrated daemon (if running the full docker-compose stack)
   - Starts discovery using the integrated daemon
   - Sets scheduled discovery sessions to run every 24 hours

4. **Monitoring discovery progress**: 
   - Switch to the **Sessions** tab to monitor progress
   - Wait 5-10+ minutes for the scan to complete (depends on your network size)

<p align="center">
  <img src="./media/first_discovery.png" width="600" alt="First Discovery">
</p>

5. **View your topology**:
   - Navigate to the **Topology** tab
   - Click **Reload** to generate your network visualization
   - Explore your discovered hosts, services, and network structure

<p align="center">
  <img src="./media/first_topology.png" width="600" alt="First Topology">
</p>

---

## 🖥️ User Interface

### Authentication

NetVisor uses username/password authentication to secure your network data. Failed login attempts are temporarily locked out after 5 attempts.

<p align="center">
  <img src="./media/login.png" width="500" alt="Login Screen">
</p>

**Using HTTPS**: When running NetVisor behind HTTPS, set `NETVISOR_USE_SECURE_SESSION_COOKIES=true` in your server configuration.

### Navigation Overview

The NetVisor interface is organized with a collapsible sidebar:

<p align="center">
  <img src="./media/navigation.png" width="300" alt="Navigation Sidebar">
</p>

#### 🔍 Discover

The Discover section contains three subtabs for managing network discovery:

**Sessions**: View and monitor active and queued discovery sessions
- Real-time progress of running scans
- Queue of pending discovery jobs

<p align="center">
  <img src="./media/discovery_sessions.png" width="800" alt="Discovery Sessions">
</p>

**Scheduled**: Schedule and manually trigger network discovery
- Schedule recurring scans
- Manually trigger scans

<p align="center">
  <img src="./media/discovery_scheduled.png" width="800" alt="Discovery Scheduled">
</p>

**History**: Review past discovery sessions
- Complete history of all discovery runs
- Detailed session information and results

<p align="center">
  <img src="./media/discovery_history.png" width="800" alt="Discovery History">
</p>

#### 📊 Manage

The Manage section groups all network organization and configuration tabs:

**🌐 Networks**: Manage multiple network environments. Each network can have its own set of daemons, hosts, and topology. Useful for:
- Separating production/staging/home networks
- Organizing networks by location or purpose
- Managing multi-tenant deployments

<p align="center">
  <img src="./media/networks_tab.png" width="800" alt="Networks Tab">
</p>

**🖥️ Hosts**: View and manage all discovered hosts on your network. Features include:
- Detailed host information (IP addresses, MAC addresses, hostnames)
- Network interface details
- Host consolidation for merging duplicates
- Manual host editing and creation
- Virtualization management (for hosts running Proxmox/Docker)

<p align="center">
  <img src="./media/hosts_tab.png" width="800" alt="Hosts Tab">
</p>

**🔧 Services**: Browse all discovered services across your network. This tab provides:
- Complete service inventory with filtering
- Service-to-host relationships
- Port bindings and protocols
- Service categories (Web, Infrastructure, Media, etc.)
- Service detection confidence scores

<p align="center">
  <img src="./media/services_tab.png" width="800" alt="Services Tab">
</p>

**🌐 Subnets**: Organize and configure network segments. Manage:
- Subnet CIDR ranges and naming
- Organizational subnets for external resources (ie services on the internet / non-local networks)

<p align="center">
  <img src="./media/subnets_tab.png" width="800" alt="Subnets Tab">
</p>

**🏷️ Groups**: Create logical service groupings and visualize relationships. Groups help you:
- Show application architectures (web app → database → cache)
- Represent containerized service clusters
- Define network paths and dependencies
- Organize hosts by function or team

<p align="center">
  <img src="./media/groups_tab.png" width="800" alt="Groups Tab">
</p>

**📡 Daemons**: Manage daemons and view their capabilities. You can view:
- What subnets daemons have interfaces with
- Whether the daemon has access to the docker socket
- When a daemon registered and was last seen

<p align="center">
  <img src="./media/daemons_tab.png" width="800" alt="Daemons Tab">
</p>

**🔑 API Keys**: Manage API Keys. You can manage:
- If an API key is enabled, disabled, and when it last expired

<p align="center">
  <img src="./media/api_keys_tab.png" width="800" alt="API Keys Tab">
</p>


#### 🗺️ Topology

Generate and customize interactive network visualizations. The topology view:
- Automatically lays out your network structure
- Shows hosts, services, subnets, and connections
- Supports extensive customization options
- Allows manual refinement of layout
- Exports to PNG

---

## 🔍 Discovery

NetVisor supports the following discovery types:

### ✋ Self-Report

The host running the daemon reports capabilities related to other discovery methods, such as whether it has access to the docker socket and what subnets it has network interfaces with.

### 🐳 Docker Discovery

If the host running the daemon is also running Docker, the daemon automatically detects containerized services by connecting to the Docker socket. This provides enhanced service discovery including:
- Container names and metadata
- Service-to-container relationships  
- Internal Docker networks
- Container ports and exposed services

### 🌐 Network Scanning

The daemon scans all IPv4 addresses on subnets it is configured to scan. 

**By Default:** The daemon will scan the subnets it has an interface with. You can also choose additional subnets it doesn't have an interface with if you think it can reach it with network requests.

For each IP on the network, the daemon:

- **Detects open ports**: Scans for active TCP ports
- **Identifies services**: Uses rule-based pattern matching to recognize running services from:
  - Open ports
  - HTTP endpoint responses
  - Response headers and content
  - IP address patterns
  - Hostname patterns
  - MAC address patterns
  - ...and more!
- **Maps interfaces**: Detects host network interfaces and their subnet membership
- **Resolves hostnames**: Performs reverse DNS lookups when possible

Discovery creates hosts with their interfaces, services, and subnet relationships. All discoveries are tracked with timestamps and confidence scores.

**Scan Duration**: Discovery typically takes 5-10+ minutes depending on:
- Number of subnets the daemon's host is connected to
- Network mask size for those subnets (must scan every IP address)
- Number of concurrent host scans configured (default: 15)
- Network response times

**Real-time Updates**: Switch to the **Discover > Sessions** tab to monitor active scans. The UI receives live updates via Server-Sent Events, showing:
- Current scan progress (scanned count / discovered count)
- Scan completion status

<p align="center">
  <img src="./media/discovery_progress.png" width="500" alt="Discovery Progress">
</p>

---

## 📊 Network Organization

### Networks

Networks are the top-level organizational unit in NetVisor. Each network represents a distinct environment and contains its own:
- Daemons
- Hosts
- Services
- Subnets
- Groups
- Scheduled discovery sessions
- Historical discovery sessions

**Use cases for multiple networks**:
- Separating home, office, and lab networks
- Managing production vs staging environments  
- Organizing networks by geographic location
- Multi-tenant deployments (e.g., managing client networks)

**Default Network**: When you first register, NetVisor creates a "My Network" network automatically. This becomes your primary network.

To create additional networks:
1. Navigate to the **Networks** tab
2. Click **Create Network**
3. Enter a name
4. Deploy daemons to the new network

### Managing Virtualization & Containers

Hosts with Proxmox or Docker services will have an additional **Virtualization** tab, allowing you to manage hosts and services that they run as VMs or containers. This changes how these hosts and services are represented in the topology visualization.

<p align="center">
  <img src="./media/virtualization_management.png" width="800" alt="Virtualization Management">
</p>

**Configuration options**:
- Mark hosts as VMs running on a Proxmox host
- Mark services as containers running on a Docker host
- Group Docker containers by host (topology option)
- Hide VM provider labels on containers (topology option)

### Consolidating Hosts

The discovery process attempts to merge duplicate hosts automatically, but this isn't always possible. You can consolidate hosts that actually represent multiple interfaces or services on the same physical/virtual machine using the **Consolidate** feature.

<p align="center">
  <img src="./media/consolidate_host_1.png" width="600" alt="Consolidate Host">
</p>
<p align="center">
  <img src="./media/consolidate_host_2.png" width="600" alt="Consolidate Host">
</p>

**What consolidation does**:
- Migrates all ports, interfaces, and services to a single host record
- Preserves all historical discovery data
- Updates topology to reflect the consolidated structure
- Cannot be undone (backup recommended if uncertain)

**When to consolidate**:
- Host appears multiple times with different IP addresses (multi-homed)
- Services on the same host are detected as separate hosts
- Duplicate hosts from multiple VLAN scans

### Subnets

Subnets organize your network into logical segments. Subnets are automatically created during discovery based on the network interfaces detected on the daemon's host.

<p align="center">
  <img src="./media/subnet_detail.png" width="800" alt="Subnet Detail">
</p>

**Subnet Properties**:
- **CIDR range**: Network address and mask (e.g., `192.168.1.0/24`)
- **Name**: Custom name or defaults to CIDR
- **Description**: Optional notes about the subnet's purpose
- **Type**: Automatically detected when found via discovery (LAN, Docker Bridge, Internet, Remote)

**Organizational Subnets**: Subnets with `0.0.0.0/0` CIDR serve as organizational containers:
- **Internet subnet**: For public services (DNS servers, cloud services)
- **Remote subnet**: For hosts on external networks (mobile devices, VPN clients, remote offices)

These subnets don't represent actual network segments but help organize external resources in your topology.

### Groups

Groups let you visualize logical connections between services, such as a web app talking to its database, or representing network paths between different parts of your infrastructure. Groups must be created manually.

<p align="center">
  <img src="./media/group_editor.gif" width="700" alt="Group Editor">
</p>

**Group Types**:
- **Hub and Spoke**: Represents multiple services that have a relationship with a hub service
- **Path**: Shows network flows or dependencies (e.g., client → proxy → backend)

**What groups do**:
- Create visual groupings in the topology
- Add edges between hosts/services to show relationships
- Help document application architectures
- Organize complex network structures

**Use cases**:
- Web application stacks (frontend, backend, database, cache)
- Docker container orchestration
- Service dependencies and data flows
- Network zones and DMZs
- Client-server relationships

---

## 🗺️ Topology Visualization

The topology view generates an interactive visualization of your network structure, automatically organizing hosts, services, subnets, and their connections.

<p align="center">
  <img src="./media/topology_full.png" width="1200" alt="Full Topology View">
</p>

**Visual Elements**:
- **Subnet containers**: Rectangles that group hosts by network segment
- **Interface nodes**: Host interfaces on subnets, and the services that are bound to those interfaces
- **Edges**: Connections showing network relationships
- **Left zone**: Separate area in subnet that can be used to separate service categories, ie if you want to show "Infrastructure"  services separate from other services

### Customization Options

The topology supports extensive customization through the options panel on the right side:

<p align="center">
  <img src="./media/topology_options.gif" width="400" alt="Topology Options Panel">
</p>

**General Options**:
- **Network selection**: Choose which networks to include in the diagram
- **Service category filters**: Hide specific service categories (Media, Development, etc.)
- **Edge type filters**: Hide certain connection types

**Docker Options**:
- **Group Docker bridges by host**: Display all containers running on a single host in one subnet grouping
- **Hide VM provider on containers**: Don't indicate the VM provider for containerized services

**Left Zone (Infrastructure) Options**:
- **Custom title**: Change the "Infrastructure" label to your preference
- **Show gateway in left zone**: Include gateway services in the infrastructure area
- **Service category selection**: Choose which service categories appear in the left zone

**Manual Adjustments**:
- **Anchor points**: Click edges to change where they connect to nodes (top, right, bottom, left)
- **Subnet sizing**: Drag subnet boundaries to resize containers
- **Node positioning**: Drag hosts and subnets to manually organize your topology

### Export

Export your topology visualization as a PNG image for documentation, presentations, or sharing:

1. Customize your topology as desired
2. Click the **Export** button in the topology header
3. PNG file downloads automatically with timestamp

The export includes your entire topology with all current customizations applied.

---

## ⚙️ Configuration

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
| Concurrent Scans | `--concurrent-scans` | `NETVISOR_CONCURRENT_SCANS` | `concurrent_scans` | - | Maximum number of hosts to scan in parallel during discovery  |
| Network ID | `--network-id` | `NETVISOR_NETWORK_ID` | `network_id` | `None` | Network ID to report discoveries to (auto-assigned for integrated daemon) |
| API Key | `--api-key` | `NETVISOR_DAEMON_API_KEY` | `daemon_api_key` | `None` | API key for daemon authentication with server (generated via UI) |
| Docker Proxy | `--docker-proxy` | `NETVISOR_DOCKER_PROXY` | `docker_proxy` | `None` | Optional HTTP proxy to use to connect to docker |

#### Configuration File Location

The daemon automatically creates and maintains a configuration file at:
- **Linux**: `~/.config/netvisor/daemon/config.json`
- **macOS**: `~/Library/Application Support/com.netvisor.daemon/config.json`
- **Windows**: `%APPDATA%\netvisor\daemon\config.json`

The configuration file persists runtime state (daemon ID, host ID, last heartbeat) alongside your configured settings.

#### Concurrent Scans
 
By default, the daemon automaticaly determines how many hosts to scan in parallel based on available system resources. However, if you encounter an error saying that CONCURRENT_SCANS is too high for the system, you can set it manually.

If set too high, the daemon may exhaust system resources and fail with an error. Monitor daemon logs and adjust as needed for your hardware.

#### Running as a System Service (Linux)

After installing the binary, you can run the daemon as a systemd service:

1. Create the service file:
```bash
sudo curl -o /etc/systemd/system/netvisor-daemon.service \
  https://raw.githubusercontent.com/mayanayza/netvisor/main/netvisor-daemon.service
```

2. Edit the service file to add your configuration:
```bash
sudo nano /etc/systemd/system/netvisor-daemon.service
```

Add your daemon arguments to the `ExecStart` line:
```ini
ExecStart=/usr/local/bin/netvisor-daemon --server-target YOUR_SERVER_IP_OR_HOSTNAME --server-port YOUR_SERVER_PORT --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY
```

3. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable netvisor-daemon
sudo systemctl start netvisor-daemon
```

4. Check status:
```bash
sudo systemctl status netvisor-daemon
```

5. View logs:
```bash
sudo journalctl -u netvisor-daemon -f
```

### Server Configuration

The server supports the following configuration options:

| Parameter | CLI Flag | Environment Variable | Default | Description |
|-----------|----------|---------------------|---------|-------------|
| Server Port | `--server-port` | `NETVISOR_SERVER_PORT` | `60072` | Port for the server to listen on |
| Log Level | `--log-level` | `NETVISOR_LOG_LEVEL` | `info` | Logging verbosity (`trace`, `debug`, `info`, `warn`, `error`) |
| Rust Log | `--rust-log` | `NETVISOR_RUST_LOG` | `""` | Low-level Rust framework logging (advanced) |
| Database URL | `--database-url` | `NETVISOR_DATABASE_URL` | `postgresql://postgres:password@localhost:5432/netvisor` | PostgreSQL connection string |
| Use Secure Cookies | `--use-secure-session-cookies` | `NETVISOR_USE_SECURE_SESSION_COOKIES` | `false` | Enable secure session cookies for HTTPS deployments |
| Integrated Daemon URL | `--integrated-daemon-url` | `NETVISOR_INTEGRATED_DAEMON_URL` | `http://172.17.0.1:60073` | URL where the server can reach the integrated daemon |
| Disable Registration | `--disable-registration` | `NETVISOR_DISABLE_REGISTRATION` | `http://172.17.0.1:60073` | Flag to disable new user registration |
| OIDC Issuer URL | `--oidc-issuer-url` | `NETVISOR_OIDC_ISSUER_URL` | - | The OIDC provider's issuer URL (must end with `/`). Example: `https://authentik.company.com/application/o/netvisor/` |
| OIDC Client ID | `--oidc-client-id` | `NETVISOR_OIDC_CLIENT_ID` | - | OAuth2 client ID from your OIDC provider |
| OIDC Client Secret | `--oidc-client-secret` | `NETVISOR_OIDC_CLIENT_SECRET` | - | OAuth2 client secret from your OIDC provider |
| OIDC Provider Name | `--oidc-provider-name` | `NETVISOR_OIDC_PROVIDER_NAME` | - | Display name shown in the UI (e.g., `Authentik`, `Keycloak`, `Auth0`) |
| OIDC Redirect URL | `--oidc-redirect-url` | `NETVISOR_OIDC_REDIRECT_URL` | - | URL from OIDC provider that NetVisor should send user to when using OIDC auth  |

#### Session Cookie Security

**Important**: Set `NETVISOR_USE_SECURE_SESSION_COOKIES=true` when running NetVisor behind HTTPS (reverse proxy or direct TLS). This ensures session cookies are marked as secure and only transmitted over HTTPS.

For internal networks without HTTPS, keep this setting as `false` (default).

#### OIDC Setup

To use OIDC, you'll need to set the following:

NETVISOR_OIDC_ISSUER_URL=https://your-provider.com/application/o/netvisor/<br>
NETVISOR_OIDC_CLIENT_ID=<your-client-id><br>
NETVISOR_OIDC_CLIENT_SECRET=<your-client-secret><br>
NETVISOR_OIDC_PROVIDER_NAME=<oidc-display-name><br>
NETVISOR_OIDC_REDIRECT_URL=<oidc-redirect-url><br>

When configuring your OIDC provider, use this callback URL:
```
http://your-netvisor-domain:60072/api/auth/oidc/callback
```
### UI Configuration

The UI automatically uses the hostname and port from your browser's address bar.

**Advanced: API on different domain**

If your API server is on a different hostname than where the UI is served (rare), rebuild the Docker image with:
```bash
docker build \
  --build-arg PUBLIC_SERVER_HOSTNAME=api.example.com \
  --build-arg PUBLIC_SERVER_PORT=8080 \
  -f backend/Dockerfile \
  -t netvisor-server:custom .
```

---

## 🔧 Troubleshooting

### Proxmox Host and LXC Issues

- If you are running containerized NetVisor directly on a Proxmox Host and encounter `could not create any Unix-domain sockets`, add the following line to the compose for both Postgres and Netvisor.
```
security_opt:
  - apparmor:unconfined
```

Refer to https://github.com/mayanayza/netvisor/issues/87 for more details
    
- If you are running in an LXC environment, you may need to change the `NETVISOR_INTEGRATED_DAEMON_URL` to `172.31.0.1.

### Error: CONCURRENT_SCANS is too high for this system

**Problem**: The daemon exhausts system memory during network scans.

**Solution**: Reduce the `NETVISOR_CONCURRENT_SCANS` environment variable. See [Concurrent Scans](#concurrent-scans) for recommended values based on your hardware.

```yaml
environment:
  NETVISOR_CONCURRENT_SCANS: 10  # Reduce from default 15
```

### Integrated Daemon Not Initializing

**Problem**: The integrated daemon (included in `docker-compose.yml`) fails to initialize after loading the UI.

**Diagnosis steps**:

1. **Check daemon logs**: 
   ```bash
   docker logs netvisor-daemon
   ```

2. **Check server logs**:
   ```bash
   docker logs netvisor-server
   ```

3. **Verify daemon accessibility**: Ensure the server can reach the daemon at the configured URL. The default `NETVISOR_INTEGRATED_DAEMON_URL` is `http://172.17.0.1:60073`, which assumes:
   - Docker's default bridge network uses `172.17.0.1` as the gateway
   - The daemon is listening on port `60073`

4. **For custom Docker networks or LXC environments**: You may need to adjust the gateway IP:
   ```yaml
   environment:
     NETVISOR_INTEGRATED_DAEMON_URL: http://<your-gateway-ip>:60073
   ```

5. **Verify bidirectional connectivity**: 
   - The daemon must be able to reach the server
   - The server must be able to reach the daemon
   - Check for firewall rules blocking communication

6. [Open a bug](https://github.com/mayanayza/netvisor/issues/new?template=bug_report.md)

### Discovery Not Finding Services

**Problem**: Network scan completes but doesn't detect expected services.

**Common causes**:

1. **Firewall blocking**: Host firewalls may block port scans
   - Temporarily disable firewall on a test host to verify
   - Configure firewall to allow scanning from daemon host

2. **Service not in definition list**: NetVisor may not have a definition for your service
   - Check [service definitions](https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions)
   - [Open an issue](https://github.com/mayanayza/netvisor/issues/new?template=missing-service-detection.md) to request new service definitions
   - Contribute service definitions following the [contribution guide](https://github.com/mayanayza/netvisor/blob/main/contributing.md)

3. **Service running on non-standard port**: Detection may fail if service uses non-standard ports
   - This is expected behavior and will not be changed. Refer to the applicable [service definition](https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions) for more details on the ports used to detect a given service. It is possible that the definition does not include ports that are actually default for the service; [open an issue](https://github.com/mayanayza/netvisor/issues/new?template=missing-service-detection.md) if so
   - In the meantime, the service can be manually categorized in the UI

### Topology Not Generating

**Problem**: Topology tab shows no visualization or errors.

**Solutions**:

1. **Ensure discovery has run**: Navigate to Discovery tab and run at least one scan
2. **Check for hosts**: Verify the Hosts tab shows discovered devices
3. **Select networks**: In topology options, ensure networks are selected
4. **Clear filters**: Check that service category and edge type filters aren't hiding everything
5. **Reload topology**: Click the Reload button to regenerate
6. **Check browser console**: Press F12 and look for JavaScript errors
7. [Open a bug](https://github.com/mayanayza/netvisor/issues/new?template=bug_report.md)

---

## ❌ Uninstall Daemon

### Linux (Docker)

```bash
docker stop netvisor-daemon
docker rm netvisor-daemon
docker volume rm netvisor_daemon-config  # Optional: remove persisted config
```

### Linux (Binary)

```bash
sudo rm /usr/local/bin/netvisor-daemon
rm -rf ~/.config/netvisor/daemon
```

### Mac (Binary)

```bash
sudo rm /usr/local/bin/netvisor-daemon
rm -rf ~/Library/Application\ Support/com.netvisor.daemon
```

### Windows (Binary)

```cmd
del %LOCALAPPDATA%\Programs\netvisor-daemon\netvisor-daemon.exe
rmdir /s %APPDATA%\netvisor\daemon
```

---

## ❓ FAQ

### Is there a hosted/cloud version?

We're working on **NetVisor Cloud**, a fully managed service that eliminates the need to run your own server. You'll get:
- Instant setup with no infrastructure management
- Automatic updates and maintenance
- Secure cloud storage
- Team collaboration features
- Multi-network management

**[Join the waitlist at netvisor.io](https://netvisor.io)** to be notified when it launches.

For now, NetVisor is available as a self-hosted solution that you can run on your own infrastructure.

### Where does NetVisor store my data?

NetVisor stores all data locally in a **PostgreSQL database** on your server. No data is sent to external services. All communication between daemon and server occurs over your local network (or VPN if configured).

**Data storage locations**:
- **Server**: PostgreSQL database (configured via docker-compose or manual setup)
- **Daemon**: Local configuration file (see [Configuration File Location](#configuration-file-location))
- **Backups**: Not automated - use standard PostgreSQL backup procedures (`pg_dump`)

### Are VLANs supported?

Yes! You can map multiple VLANs in two ways:

**Option 1: Deploy multiple daemons**

1. Navigate to **Manage > Daemons** in the sidebar
2. Click **"Create New Daemon"** for each VLAN you want to scan
3. Deploy each daemon on a host connected to the target VLAN
4. Run discovery from each daemon

Each daemon will discover its local network segment. You may need to use the [Consolidate](#consolidating-hosts) feature to merge hosts that appear on multiple VLANs with different IP addresses.

**Option 2: Add subnets that the daemon should be able to reach hosts on, even if it doesn't have a direct network interface with that subnet**

1. Navigate to **Manage > Subnets** in the sidebar
2. Create a new subnet for each CIDR you want to scan
3. Navigate to **Discover > Scheduled** in the sidebar
4. Create a scheduled discovery, discovery type: Network Scan
5. Add the subnets you just created to the scan and run it

**Note**: if scanning a subnet with which it doesn't have an interface, the daemon will not be able to collect MAC addresses or hostnames from any detected hosts.

### Is IPv6 supported?

Not currently. IPv6 support is planned for future releases with the following scope:

**Planned features**:
- Collecting and displaying a host's IPv6 address during discovery
- Manual entry of IPv6 addresses when editing hosts
- IPv6 connectivity testing for known hosts

**Not planned**:
- Full IPv6 subnet scanning (scanning the entire IPv6 space of a /64 subnet would take far too long)

If you need IPv6 support sooner, please [open an issue](https://github.com/mayanayza/netvisor/issues/new) describing your use case.

### What services can NetVisor discover?

NetVisor automatically detects **50+ common services** including:

**Media Servers**: Plex, Jellyfin, Emby, Tautulli  
**Home Automation**: Home Assistant, HomeKit, Philips Hue Bridge  
**Virtualization & Containers**: Proxmox, Docker, Kubernetes, Portainer  
**Network Infrastructure**: Pi-hole, AdGuard Home, Unifi Controller, pfSense, OPNsense  
**Storage & File Sharing**: Synology DSM, QNAP, TrueNAS, Nextcloud, Samba  
**Monitoring & Observability**: Grafana, Prometheus, Uptime Kuma, Netdata  
**Reverse Proxies & CDN**: Nginx Proxy Manager, Traefik, Caddy, Cloudflared  
**Databases**: PostgreSQL, MySQL/MariaDB, MongoDB, Redis  
**Communication**: Asterisk, FreePBX, UniFi Talk  
**Web Servers**: Apache, Nginx, Lighttpd  
**Development**: GitLab, Gitea, Jenkins, Ansible AWX  
**Security**: Wazuh, Zabbix, Firewalla

For a **complete list**, see the [service definitions directory](https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions).

**Service not detected?**
- If your service is on this list but wasn't detected: [Open a bug report](https://github.com/mayanayza/netvisor/issues/new?template=missing-service-detection.md)
- If your service isn't on this list and you'd like it added: [Request a service definition](https://github.com/mayanayza/netvisor/issues/new?template=missing-service-detection.md)
- Want to contribute? See our [service definition contribution guide](https://github.com/mayanayza/netvisor/blob/main/contributing.md#adding-service-definitions)

### Can I run NetVisor without Docker?

**Server**: Requires Docker (or manual PostgreSQL + Rust + Node.js setup for development)

**Daemon**: Yes! The daemon is available as a standalone binary for:
- Linux (x86_64, ARM64)
- macOS (x86_64, ARM64)  
- Windows (x86_64)

Download from the [releases page](https://github.com/mayanayza/netvisor/releases) or use the install script:

```bash
curl -sSL https://raw.githubusercontent.com/mayanayza/netvisor/main/install.sh | bash
```

### How do I contribute?

We welcome contributions! See our [contributing guide](https://github.com/mayanayza/netvisor/blob/main/contributing.md) for:
- Adding service definitions (great first contribution!)
- Reporting bugs
- Requesting features
- Submitting pull requests
- Code style and testing guidelines

Join our [Discord community](https://discord.gg/b7ffQr8AcZ) for help and discussions.

---

**License**: [View License](https://github.com/mayanayza/netvisor/blob/main/LICENSE)  
**Issues**: [Report a bug or request a feature](https://github.com/mayanayza/netvisor/issues/new)  
**Discussions**: [Join our Discord](https://discord.gg/b7ffQr8AcZ)
