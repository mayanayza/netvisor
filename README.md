# Scanopy

<p align="left">
  <img src="./media/logo.png" width="100" alt="Scanopy Logo">
</p>

**Clean network diagrams. One-time setup, zero upkeep.**

Scanopy scans your network, identifies hosts and services, and generates an interactive visualization showing how everything connects, letting you easily create and maintain network documentation.

![Docker Pulls](https://img.shields.io/docker/pulls/mayanayza/netvisor-server?style=for-the-badge&logo=docker)  ![Github Stars](https://img.shields.io/github/stars/scanopy/scanopy?style=for-the-badge&logo=github
)<br>
![GitHub release](https://img.shields.io/github/v/release/scanopy/scanopy?style=for-the-badge) ![License](https://img.shields.io/github/license/scanopy/scanopy?style=for-the-badge)<br>
![Daemon image size](https://img.shields.io/docker/image-size/mayanayza/scanopy-daemon?style=for-the-badge&label=Daemon%20image%20size) ![Server image size](https://img.shields.io/docker/image-size/mayanayza/scanopy-server?style=for-the-badge&label=Server%20image%20size
)<br>
![Daemon](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/daemon-ci.yml?label=daemon-ci&style=for-the-badge)  ![Server](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/server-ci.yml?label=server-ci&style=for-the-badge)  ![UI](https://img.shields.io/github/actions/workflow/status/scanopy/scanopy/ui-ci.yml?label=ui-ci&style=for-the-badge)<br>
[![Discord](https://img.shields.io/discord/1432872786828726392?logo=discord&label=discord&labelColor=white&color=7289da&style=for-the-badge)](https://discord.gg/b7ffQr8AcZ)

> 💡 **Prefer not to self-host?** [Get a free trial](https://scanopy.net) of Scanopy Cloud

<p align="center">
  <img src="./media/hero.png" width="1200" alt="Example Visualization">
</p>

## ✨ Key Features

- **Automatic Discovery**: Scans networks to identify hosts, services, and their relationships
- **200+ Service Definitions**: Auto-detects databases, web servers, containers, network infrastructure, monitoring tools, and enterprise applications
- **Interactive Topology**: Generates visual network diagrams with extensive customization options
- **Distributed Scanning**: Deploy daemons across network segments to map complex topologies
- **Docker Integration**: Discovers containerized services automatically
- **Organization Management**: Multi-user support with role-based permissions
- **Scheduled Discovery**: Automated scanning to keep documentation current

## 🎯 Perfect For

- **Home Lab Enthusiasts**: Document your ever-growing infrastructure
- **IT Professionals**: Maintain accurate network inventory without manual spreadsheets  
- **System Administrators**: Visualize complex multi-VLAN environments
- **DevOps Teams**: Map containerized services and their dependencies
- **MSPs**: Manage multiple client networks with separate organizations

## 🚀 Quick Start

**Docker Compose**

```bash
curl -O https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/docker-compose.yml
docker compose up -d
```

**Proxmox**

Use this [helper script](https://community-scripts.github.io/ProxmoxVE/scripts?id=scanopy) to create a Scanopy LXC.

**Unraid**

Available as an Unraid community app.

---

Access the UI at `http://<your-server-ip>:60072`, create your account, and wait for the first discovery to complete.

For detailed setup options and configuration, see the [Installation Guide](https://scanopy.net/docs/self-hosted/server-installation).

## 📚 Documentation

Full documentation at **[scanopy.net/docs](https://scanopy.net/docs)**

## 📋 Licensing

**Personal/Home Use**: Free under [AGPL-3.0](LICENSE.md)

**Commercial Use**: 
- **Self-hosted**: [Commercial license](COMMERCIAL-LICENSE.md) required for businesses, MSPs, or proprietary integrations. Contact licensing@scanopy.net
- **Hosted Solution**: [Scanopy Cloud](https://scanopy.net) subscription for zero infrastructure management

## 🤝 Contributing

We welcome contributions! See our [contributing guide](contributing.md) for details.

Great first contribution: [adding service definitions](contributing.md#adding-service-definitions)

## 💬 Community & Support

- **Discord**: [Join our Discord](https://discord.gg/b7ffQr8AcZ) for help and discussions
- **Issues**: [Report bugs or request features](https://github.com/scanopy/scanopy/issues/new)
- **Discussions**: [GitHub Discussions](https://github.com/scanopy/scanopy/discussions)

---

**Built with ❤️ in NYC**
