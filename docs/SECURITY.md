# Scanopy Security Overview

## Data Collection

### What Data is Collected

Scanopy stores information about devices and services on networks you configure for scanning:

- **Network devices**: IP addresses, MAC addresses, hostnames, device types
- **Services**: Open ports, protocol information
- **Topology**: Network relationships and connectivity between devices
- **Metadata**: Discovery timestamps, scan configurations

### Data Storage

- **Self-hosted**: All data is stored locally in your PostgreSQL database. No data is sent to external servers.
- **Scanopy Cloud**: Data is stored in our secure cloud infrastructure. See our [Privacy Policy](https://scanopy.net/privacy) for details.

## Network Behavior

### Daemon Communication

Scanopy daemon communicates with the server using:

- **Pull mode** (default): Daemon polls the server for scan instructions
- **Push mode**: Server connects to daemon to initiate scans (requires daemon to be accessible from server)

### Network Discovery

The daemon performs passive and active network discovery:

- ARP scanning to discover devices on local network segments
- Port scanning to identify running services
- Optional Docker API inspection for container discovery

## Encryption

- **Scanopy Cloud**: All communication uses HTTPS/TLS encryption
- **Self-hosted**: HTTP by default for local deployments. HTTPS should be configured if exposing the server over the internet (via reverse proxy like nginx, Caddy, or Traefik)

## Permissions

### Daemon Requirements

The Scanopy daemon requires elevated permissions for network scanning:

- **Linux**: Root access or `CAP_NET_RAW` capability for raw socket access (ARP scanning)
- **Docker**: Access to Docker socket for container discovery (optional)
- **macOS/Windows**: Administrator privileges for network scanning

### Server Requirements

The Scanopy server runs as a standard user process with no special permissions required.

## External Connections

### Self-hosted Deployments

Self-hosted Scanopy makes minimal external connections:

- **Docker Hub / GitHub Container Registry**: For pulling container images (if using Docker deployment)
- **No telemetry**: No usage data is sent to Scanopy or third parties

### Scanopy Cloud

Cloud deployments connect to:

- Scanopy API servers for data synchronization
- PostHog for anonymous usage analytics (can be opted out via cookie settings)
- Plunk for transactional emails, and marketing emails (which can be opted out during registration)
- Stripe for payment processing (billing-related only)

## Reporting Security Issues

If you discover a security vulnerability, please report it responsibly:

- Email: security@scanopy.net
- Do not disclose publicly until we've had a chance to address the issue

## Questions?

For security-related questions not covered here, contact us at security@scanopy.net.
