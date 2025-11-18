# NetVisor

<p align="left">
  <img src="./media/logo.png" width="100" alt="NetVisor Logo">
</p>

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
  <img src="./media/hero.png" width="1200" alt="Example Visualization">
</p>

## ✨ Key Features

- **Automatic Discovery**: Scans networks to identify hosts, services, and their relationships
- **200+ Service Definitions**: Auto-detects databases, web servers, containers, network infrastructure, monitoring tools, and enterprise applications
- **Interactive Topology**: Generates visual network diagrams with extensive customization options
- **Multi-VLAN Support**: Deploy daemons and scan across network segments to map complex topologies
- **Docker Integration**: Discovers containerized services automatically
- **Organization Management**: Multi-user support with role-based permissions (Owner, Admin, Member, Visualizer)
- **Scheduled Discovery**: Automated scanning to keep documentation current
- **Export & Share**: Download topology diagrams as PNG images

## 🎯 Perfect For

- **Home Lab Enthusiasts**: Document your ever-growing infrastructure
- **IT Professionals**: Maintain accurate network inventory without manual spreadsheets  
- **System Administrators**: Visualize complex multi-VLAN environments
- **DevOps Teams**: Map containerized services and their dependencies
- **MSPs**: Manage multiple client networks with separate organizations

---

**Want hosted NetVisor without the setup?** Get early access to our upcoming cloud service at [netvisor.io](https://netvisor.io)

---

## 📚 Documentation

- **[Installation Guide](./docs/INSTALLATION.md)** - Detailed setup instructions for all platforms
- **[User Guide](./docs/USER_GUIDE.md)** - Complete guide to using NetVisor features
- **[Configuration Reference](./docs/CONFIGURATION.md)** - Server, daemon, and environment variables
- **[Architecture Overview](./docs/ARCHITECTURE.md)** - System design and technology stack

## 🚀 Quick Start

### Prerequisites

- **Server**: Docker and Docker Compose
- **Daemon** (included in default setup): Docker with host networking, or standalone binary

### Installation

1. **Start the server** (includes integrated daemon):

**Docker Compose**

```bash
curl -O https://raw.githubusercontent.com/mayanayza/netvisor/refs/heads/main/docker-compose.yml && docker compose up -d
```

**Proxmox**

You can use this [helper script](https://community-scripts.github.io/ProxmoxVE/scripts?id=netvisor) to create a NetVisor LXC on your Proxmox host.

**Unraid**

NetVisor is available as an Unraid community app.

2. **Access the UI** at `http://<your-server-ip>:60072`

3. **Create your account** on the registration page

4. **Wait for first discovery** to complete (5-10+ minutes depending on network size)

That's it! NetVisor automatically:
- Creates a default network
- Starts the integrated daemon
- Runs initial discovery
- Schedules daily scans

### Next Steps

- **View your topology**: Navigate to Topology to see the network diagram
- **Scan additional VLANs**: Deploy more daemons at **Manage > Daemons** or add subnets to your existing daemon's scan list in **Discover > Scheduled**
- **Organize your network**: Create groups, consolidate hosts, manage subnets

See the [User Guide](USER_GUIDE.md) for detailed feature documentation.

## 🔍 What Gets Discovered?

NetVisor automatically detects **200+ common services** including:

**Infrastructure & Networking**: Pi-hole, AdGuard Home, Unifi Controller, pfSense, OPNsense  
**Virtualization & Containers**: Proxmox, Docker, Kubernetes, Portainer  
**Databases**: PostgreSQL, MySQL/MariaDB, MongoDB, Redis, Microsoft SQL Server  
**Web Servers & Proxies**: Apache, Nginx, Lighttpd, Traefik, Caddy, HAProxy  
**Monitoring & Observability**: Grafana, Prometheus, Zabbix, Netdata, Nagios  
**Storage & File Sharing**: Synology DSM, QNAP, TrueNAS, Nextcloud, Samba, Windows File Server  
**Development & CI/CD**: GitLab, Jenkins, Ansible AWX, GitHub Enterprise, Azure DevOps  
**Communication & Collaboration**: Microsoft Exchange, Asterisk, FreePBX, Rocket.Chat  
**Media & Content**: Plex, Jellyfin, Emby, streaming servers  
**Automation & IoT**: Home Assistant, Node-RED, MQTT brokers

For the complete list, see the [service definitions directory](https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions).

**Missing a service?** [Request it](https://github.com/mayanayza/netvisor/issues/new?template=missing-service-detection.md) or [contribute a definition](contributing.md#adding-service-definitions)!

## 🛠️ Technology Stack

- **Backend**: Rust with Axum web framework
- **Frontend**: Svelte 5 with SvelteKit
- **Database**: PostgreSQL 17
- **Visualization**: @xyflow/svelte for topology rendering
- **Deployment**: Docker and Docker Compose

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design.

## 🤝 Contributing

We welcome contributions! Whether you're:
- Adding service definitions (great first contribution!)
- Reporting bugs
- Requesting features
- Submitting pull requests

See our [contributing guide](contributing.md) for details.

## 💬 Community & Support

- **Documentation**: You're reading it! Check the [User Guide](USER_GUIDE.md) for detailed features
- **Discord**: [Join our Discord](https://discord.gg/b7ffQr8AcZ) for help and discussions
- **Issues**: [Report bugs or request features](https://github.com/mayanayza/netvisor/issues/new)
- **Discussions**: [GitHub Discussions](https://github.com/mayanayza/netvisor/discussions)

## 📋 FAQ

**Can I run NetVisor without Docker?**

The server requires Docker (or manual PostgreSQL + Rust + Node.js setup for development). The daemon is available as a standalone binary for Linux, macOS, and Windows.

**How do I scan multiple VLANs?**

Deploy multiple daemons—one per VLAN you want to scan. Each daemon connects to the server and discovers its local network segment. See [Multi-VLAN Setup](USER_GUIDE.md#multi-vlan-setup) in the User Guide.

**Is IPv6 supported?**

Not currently. IPv6 support is planned for displaying IPv6 addresses and connectivity testing, but not full subnet scanning. See [User Guide FAQ](USER_GUIDE.md#faq) for details.

**How long does discovery take?**

Typically 5-10+ minutes depending on network size, subnet masks, and concurrent scan settings. Monitor progress in **Discover > Sessions**.

**Can I customize the topology layout?**

Yes! Extensive customization options including network filters, service category hiding, Docker grouping, edge type filters, manual node positioning, and subnet resizing. See [Topology Visualization](USER_GUIDE.md#topology-visualization).

## 📄 License

NetVisor is dual-licensed:

- **Open Source**: [AGPL-3.0](LICENSE.md) - Free for self-hosted, open source use
- **Commercial**: [Commercial licensing available](COMMERCIAL-LICENSE.md) for organizations that need to use NetVisor without AGPL requirements

---

**Built with ❤️ in NYC**
