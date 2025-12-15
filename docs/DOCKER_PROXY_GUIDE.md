# Docker Socket Proxy Guide

Guide for configuring Docker socket proxies with Scanopy daemons.

## Table of Contents

- [Overview](#overview)
- [When to Use a Docker Proxy](#when-to-use-a-docker-proxy)
- [Supported Proxies](#supported-proxies)
- [Configuration](#configuration)

## Overview

Scanopy daemons can discover Docker containers by connecting to the Docker API. By default, daemons connect directly to `/var/run/docker.sock`. A Docker socket proxy provides an additional security layer by restricting which Docker API operations are allowed.

## When to Use a Docker Proxy

### Direct Socket Access (Default)

Mount the Docker socket directly:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

**Use when:**
- Daemon runs on same host as Docker
- You trust the daemon with full Docker API access
- Simplest setup

### Docker Socket Proxy

Route requests through a proxy:

```yaml
environment:
  - SCANOPY_DOCKER_PROXY=http://docker-proxy:2375
```

**Use when:**
- You want to restrict Docker API operations
- Daemon runs in a more restricted security context
- Compliance requires limiting Docker access

## Supported Proxies

Scanopy has been tested with these Docker socket proxies:

### Tecnativa docker-socket-proxy

```yaml
services:
  docker-proxy:
    image: tecnativa/docker-socket-proxy
    environment:
      - CONTAINERS=1      # Required: list and inspect containers
      - NETWORKS=1        # Required: list networks for subnet discovery
      - EXEC=1            # Required: exec into containers for endpoint probing
      - POST=1            # Required: create exec instances
      - INFO=1            # Optional: system info
      - BUILD=0
      - COMMIT=0
      - CONFIGS=0
      - DISTRIBUTION=0
      - GRPC=0
      - IMAGES=0
      - NODES=0
      - PLUGINS=0
      - SECRETS=0
      - SERVICES=0
      - SESSION=0
      - SWARM=0
      - SYSTEM=0
      - TASKS=0
      - VOLUMES=0
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    ports:
      - "2375:2375"
```

### wollomatic socket-proxy

```yaml
services:
  docker-proxy:
    image: wollomatic/socket-proxy
    environment:
      - ALLOW_RESTARTS=0
      - LOG_LEVEL=info
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    ports:
      - "2375:2375"
```

Note: wollomatic's proxy uses allowlists. Refer to their documentation for configuring the required endpoints.

## Configuration

### HTTP Proxy (Non-SSL)

```yaml
# Daemon configuration
environment:
  - SCANOPY_DOCKER_PROXY=http://docker-proxy:2375
```

Or via CLI:
```bash
scanopy-daemon --docker-proxy http://docker-proxy:2375 ...
```

### HTTPS Proxy (SSL)

For SSL-enabled proxies, provide certificate paths:

```yaml
environment:
  - SCANOPY_DOCKER_PROXY=https://docker-proxy:2376
  - SCANOPY_DOCKER_PROXY_SSL_CERT=/certs/client-cert.pem
  - SCANOPY_DOCKER_PROXY_SSL_KEY=/certs/client-key.pem
  - SCANOPY_DOCKER_PROXY_SSL_CHAIN=/certs/ca.pem
volumes:
  - ./certs:/certs:ro
```

Or via CLI:
```bash
scanopy-daemon \
  --docker-proxy https://docker-proxy:2376 \
  --docker-proxy-ssl-cert /certs/client-cert.pem \
  --docker-proxy-ssl-key /certs/client-key.pem \
  --docker-proxy-ssl-chain /certs/ca.pem \
  ...
```

### Required Docker API Permissions

Scanopy daemon uses the following Docker API endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/containers/json` | GET | List running containers |
| `/containers/{id}/json` | GET | Get container details (ports, networks, config) |
| `/networks` | GET | List Docker networks for subnet discovery |
| `/exec/{id}/json` | GET | Check exec instance status |
| `/containers/{id}/exec` | POST | Create exec instance for endpoint probing |
| `/exec/{id}/start` | POST | Start exec to probe HTTP endpoints inside containers |

**Note on exec**: Scanopy uses `exec` to probe HTTP endpoints from inside containers. This enables service detection for containers that don't expose ports to the host. If you disable exec access, containers will still be discovered but service detection accuracy may be reduced.

### Common Issues

#### "Connection refused" to proxy

1. Verify proxy is running: `docker ps | grep proxy`
2. Check proxy is listening: `curl http://docker-proxy:2375/version`
3. Ensure daemon can reach proxy (same Docker network or exposed port)

#### "Permission denied" from proxy

Proxy is blocking required endpoints. For Tecnativa, ensure:
- `CONTAINERS=1`
- `NETWORKS=1`
- `EXEC=1` (for endpoint probing)
- `POST=1` (required for exec)

#### SSL certificate errors

1. Verify certificate paths are correct and mounted
2. Check certificate is valid: `openssl x509 -in /certs/client-cert.pem -text -noout`
3. Ensure CA chain is included if using self-signed certs

---

For daemon configuration options, see [CONFIGURATION.md - Daemon Configuration](CONFIGURATION.md#daemon-configuration).
