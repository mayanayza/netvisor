# Scanopy

<p align="left">
  <img src="./media/logo.png" width="100" alt="Scanopy Logo">
</p>

**Automatically discover and visually document network infrastructure.**

Scanopy scans your network, identifies hosts and services, and generates an interactive visualization showing how everything connects, letting you easily create and maintain network documentation.<br>
<br>
![Docker Pulls](https://img.shields.io/docker/pulls/mayanayza/netvisor-server?style=for-the-badge&logo=docker)  ![Github Stars](https://img.shields.io/github/stars/scanopy/scanopy?style=for-the-badge&logo=github
)<br>
![GitHub release](https://img.shields.io/github/v/release/scanopy/scanopy?style=for-the-badge) ![License](https://img.shields.io/github/license/scanopy/scanopy?style=for-the-badge)<br>
![Daemon image size](https://img.shields.io/docker/image-size/mayanayza/scanopy-daemon?style=for-the-badge&label=Daemon%20image%20size) ![Server image size](https://img.shields.io/docker/image-size/mayanayza/scanopy-server?style=for-the-badge&label=Server%20image%20size
)<br>
![Daemon](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/daemon-ci.yml?label=daemon-ci&style=for-the-badge)  ![Server](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/server-ci.yml?label=server-ci&style=for-the-badge)  ![UI](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/ui-ci.yml?label=ui-ci&style=for-the-badge)<br>
[![Discord](https://img.shields.io/discord/1432872786828726392?logo=discord&label=discord&labelColor=white&color=7289da&style=for-the-badge)](https://discord.gg/b7ffQr8AcZ)

> 💡 **Prefer not to self-host?** [Get a free trial](https://scanopy.net) of Scanopy Cloud
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

## 📋 Licensing & Deployment Options

Choose the right option for your use case:

| Use Case | License | Cost | Best For |
|----------|---------|------|----------|
| **Personal/Home Use** | [AGPL-3.0](LICENSE.md) | Free | Home labs, personal networks, learning |
| **Commercial Use** | [Commercial License](COMMERCIAL-LICENSE.md) | [Contact Us](mailto:licensing@scanopy.net) | Businesses, MSPs, proprietary integrations |
| **Hosted Solution** | [Scanopy Cloud](https://scanopy.net) | Subscription | Individuals and teams wanting Scanopy with zero infrastructure management |

### License Selection Guide

**Use AGPL-3.0 (free) if:**
- Using Scanopy for personal/home network documentation
- Comfortable with self-hosting and maintenance
- OK with AGPL copyleft obligations

**Need a Commercial License if:**
- Using Scanopy for business/company networks
- Providing Scanopy as a service to clients (MSPs, consultants)
- Integrating Scanopy into proprietary software
- Don't want to disclose modifications or comply with AGPL requirements

For commercial licensing inquiries: **licensing@scanopy.net**

**Choose Scanopy Cloud if:**
- Want a fully managed solution without infrastructure setup
- Prefer subscription pricing over self-hosting

**[Scanopy Cloud Free Trial →](https://scanopy.net)**

## 🎯 Perfect For

- **Home Lab Enthusiasts**: Document your ever-growing infrastructure
- **IT Professionals**: Maintain accurate network inventory without manual spreadsheets  
- **System Administrators**: Visualize complex multi-VLAN environments
- **DevOps Teams**: Map containerized services and their dependencies
- **MSPs**: Manage multiple client networks with separate organizations

## 📚 Documentation

- **[Installation Guide](./docs/INSTALLATION.md)** - Detailed setup instructions for all platforms
- **[User Guide](./docs/USER_GUIDE.md)** - Complete guide to using Scanopy features
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
    curl -O https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/docker-compose.yml && docker compose up -d
    ```
    
    **Proxmox**
    
    You can use this [helper script](https://community-scripts.github.io/ProxmoxVE/scripts?id=scanopy) to create a Scanopy LXC on your Proxmox host.
    
    **Unraid**
    
    Scanopy is available as an Unraid community app.

2. **Access the UI** at `http://<your-server-ip>:60072`

3. **Create your account** on the registration page

4. **Wait for first discovery** to complete (5-10+ minutes depending on network size)

That's it! Scanopy automatically:
- Creates a default network
- Starts the integrated daemon
- Runs initial discovery
- Schedules daily scans

### Next Steps

- **View your topology**: Navigate to Topology to see the network diagram
- **Scan additional VLANs**: Deploy more daemons at **Manage > Daemons** or add subnets to your existing daemon's scan list in **Discover > Scheduled**
- **Organize your network**: Create groups, consolidate hosts, manage subnets

See the [User Guide](./docs/USER_GUIDE.md) for detailed feature documentation.

## 🔍 What Gets Discovered?

Scanopy automatically detects **200+ common services** including:

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

For the complete list, see the [service definitions directory](./docs/SERVICES.md).

**Missing a service?** [Request it](https://github.com/scanopy/scanopy/issues/new?template=missing-service-detection.md) or [contribute a definition](contributing.md#adding-service-definitions)!

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
- **Issues**: [Report bugs or request features](https://github.com/scanopy/scanopy/issues/new)
- **Discussions**: [GitHub Discussions](https://github.com/scanopy/scanopy/discussions)

## 📋 FAQ

**Can I run Scanopy without Docker?**

The server requires Docker (or manual PostgreSQL + Rust + Node.js setup for development). The daemon is available as a standalone binary for Linux, macOS, and Windows.

**How do I scan multiple VLANs?**

Deploy multiple daemons—one per VLAN you want to scan. Each daemon connects to the server and discovers its local network segment. See [Multi-VLAN Setup](USER_GUIDE.md#multi-vlan-setup) in the User Guide.

**Is IPv6 supported?**

Not currently. IPv6 support is planned for displaying IPv6 addresses and connectivity testing, but not full subnet scanning. See [User Guide FAQ](USER_GUIDE.md#faq) for details.

**How long does discovery take?**

Typically 5-10+ minutes depending on network size, subnet masks, and concurrent scan settings. Monitor progress in **Discover > Sessions**.

**Can I customize the topology layout?**

Yes! Extensive customization options including network filters, service category hiding, Docker grouping, edge type filters, manual node positioning, and subnet resizing. See [Topology Visualization](USER_GUIDE.md#topology-visualization).

---

**Built with ❤️ in NYC**
