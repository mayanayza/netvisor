# Configuration Reference

Complete reference for configuring NetVisor server and daemon components.

## Table of Contents

- [Configuration Priority](#configuration-priority)
- [Daemon Configuration](#daemon-configuration)
- [Server Configuration](#server-configuration)
- [UI Configuration](#ui-configuration)
- [OIDC Setup](#oidc-setup)
- [Session Security](#session-security)
- [Environment Files](#environment-files)

## Configuration Priority

NetVisor uses the following priority order (highest to lowest):

1. **Command-line arguments** (highest priority)
2. **Environment variables**
3. **Configuration file** (daemon only)
4. **Default values** (lowest priority)

Later sources override earlier ones. For example, an environment variable overrides the config file but is overridden by a command-line argument.

## Daemon Configuration

### Configuration Methods

**Command-line arguments**:
```bash
netvisor-daemon --server-url http://192.168.1.100:60072 --api-key YOUR_KEY
```

**Environment variables**:
```bash
export NETVISOR_SERVER_URL=http://192.168.1.100:60072
export NETVISOR_DAEMON_API_KEY=YOUR_KEY
netvisor-daemon
```

**Docker environment**:
```yaml
environment:
  - NETVISOR_SERVER_URL=http://192.168.1.100:60072
  - NETVISOR_DAEMON_API_KEY=YOUR_KEY
```

**Configuration file**:

The daemon automatically creates a config file at:
- **Linux**: `~/.config/netvisor/daemon/config.json`
- **macOS**: `~/Library/Application Support/com.netvisor.daemon/config.json`
- **Windows**: `%APPDATA%\netvisor\daemon\config.json`

The config file stores runtime state (daemon ID, host ID) alongside your settings. Command-line and environment variables take priority over the file.

### Parameter Reference

| Parameter | CLI Flag | Environment Variable | Config File Key | Default | Description |
|-----------|----------|---------------------|-----------------|---------|-------------|
| **Server URL** | `--server-url` | `NETVISOR_SERVER_URL` | `server_url` | `http://127.0.0.1:60072` | URL where the daemon can reach the server |
| **API Key** | `--api-key` | `NETVISOR_DAEMON_API_KEY` | `daemon_api_key` | *Required* | Authentication key for daemon (generated via UI) |
| **Mode** | `--mode` | `NETVISOR_MODE` | `mode` | Push | Whether server will push work to daemon or daemon should poll for work from server |
| **Network ID** | `--network-id` | `NETVISOR_NETWORK_ID` | `network_id` | *Auto-assigned* | UUID of the network to scan |
| **Daemon Port** | `--daemon-port` or `-p` | `NETVISOR_DAEMON_PORT` | `daemon_port` | `60073` | Port for daemon to listen on |
| **Bind Address** | `--bind-address` | `NETVISOR_BIND_ADDRESS` | `bind_address` | `0.0.0.0` | IP address to bind daemon to |
| **Daemon Name** | `--name` | `NETVISOR_NAME` | `name` | `netvisor-daemon` | Human-readable name for this daemon |
| **Log Level** | `--log-level` | `NETVISOR_LOG_LEVEL` | `log_level` | `info` | Logging verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| **Heartbeat Interval** | `--heartbeat-interval` | `NETVISOR_HEARTBEAT_INTERVAL` | `heartbeat_interval` | `30` | Seconds between heartbeat updates / work requests (for daemons in pull mode) to server |
| **Concurrent Scans** | `--concurrent-scans` | `NETVISOR_CONCURRENT_SCANS` | `concurrent_scans` | *Auto* | Maximum parallel host scans during discovery |
| **Docker Proxy** | `--docker-proxy` | `NETVISOR_DOCKER_PROXY` | `docker_proxy` | *None* | Optional HTTP proxy for Docker API connections |

### Concurrent Scans

Controls how many hosts the daemon scans simultaneously during network discovery.

**Default behavior**: Auto-detected based on system resources
- Calculates based on available memory
- Typical range: 10-20 for most systems
- Adjusts to prevent memory exhaustion

**When to set manually**:
- System crashes during scans
- Memory errors in logs
- Very large networks (100+ hosts)
- Resource-constrained devices (Raspberry Pi)

**Recommended values**:
- **Raspberry Pi 4 (4GB)**: 5-10
- **Standard desktop**: 15-20
- **Server**: 20-30+
- **Low memory**: Start with 5, increase gradually

**Setting**:
```bash
# CLI
netvisor-daemon --concurrent-scans 10

# Environment
export NETVISOR_CONCURRENT_SCANS=10

# Docker
environment:
  - NETVISOR_CONCURRENT_SCANS=10
```

**Symptoms of too high**:
- Daemon crashes during scans
- "CONCURRENT_SCANS too high for this system" error
- Out of memory errors
- System becomes unresponsive

**Impact**:
- Lower value = slower scans, more stable
- Higher value = faster scans, more memory usage

## Server Configuration

### Configuration Methods

**Environment variables in docker-compose**:
```yaml
environment:
  - NETVISOR_SERVER_PORT=60072
  - DATABASE_URL=postgresql://postgres:password@db:5432/netvisor
```

**Command-line** (for binary builds):
```bash
./netvisor-server --port 60072 --database-url postgresql://...
```

### Parameter Reference

| Parameter | CLI Flag | Environment Variable | Default | Description |
|-----------|----------|---------------------|---------|-------------|
| **Server Public URL** | `--public-url` | `NETVISOR_PUBLIC_URL` | `http://localhost:60072` | Public URL for webhooks, email links, etc |
| **Server Port** | `--server-port` | `NETVISOR_SERVER_PORT` | `60072` | Port for server to listen on |
| **Database URL** | `--database-url` | `NETVISOR_DATABASE_URL` | *Required* | PostgreSQL connection string |
| **Log Level** | `--log-level` | `NETVISOR_LOG_LEVEL` | `info` | Logging verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| **Secure Cookies** | `--use-secure-session-cookies` | `NETVISOR_USE_SECURE_SESSION_COOKIES` | `false` | Enable HTTPS-only cookies |
| **Integrated Daemon URL** | `--integrated-daemon-url` | `NETVISOR_INTEGRATED_DAEMON_URL` | `http://172.17.0.1:60073` | URL to reach daemon in default docker compose |
| **Disable Registration** | `--disable-registration` | `NETVISOR_DISABLE_REGISTRATION` | `false` | Disable new user registration |
| **OIDC Issuer URL** | `--oidc-issuer-url` | `NETVISOR_OIDC_ISSUER_URL` | - | OIDC provider's issuer URL (must end with `/`) |
| **OIDC Client ID** | `--oidc-client-id` | `NETVISOR_OIDC_CLIENT_ID` | - | OAuth2 client ID from provider |
| **OIDC Client Secret** | `--oidc-client-secret` | `NETVISOR_OIDC_CLIENT_SECRET` | - | OAuth2 client secret from provider |
| **OIDC Provider Name** | `--oidc-provider-name` | `NETVISOR_OIDC_PROVIDER_NAME` | - | Display name shown in UI (e.g., "Authentik", "Keycloak") |
| **OIDC Redirect URL** | `--oidc-redirect-url` | `NETVISOR_OIDC_REDIRECT_URL` | - | URL from OIDC provider for authentication redirect |
| **SMTP Username** | `--smtp-username` | `NETVISOR_SMTP_USERNAME` | - | SMTP username for email features (password reset, notifications) |
| **SMTP Password** | `--smtp-password` | `NETVISOR_SMTP_PASSWORD` | - | SMTP password for email authentication |
| **SMTP Relay** | `--smtp-relay` | `NETVISOR_SMTP_RELAY` | - | SMTP server address (e.g., `smtp.gmail.com`) |
| **SMTP Email** | `--smtp-email` | `NETVISOR_SMTP_EMAIL` | - | Sender email address for outgoing emails |

### Integrated Daemon URL

The integrated daemon runs in a separate container and needs to reach the server. The default assumes Docker's bridge network gateway is `172.17.0.1`.

**Check your bridge gateway**:
```bash
docker network inspect bridge | grep Gateway
```

**If different**, update in docker-compose.yml:
```yaml
environment:
  - NETVISOR_INTEGRATED_DAEMON_URL=http://YOUR_GATEWAY_IP:60073
```

### SMTP Configuration

SMTP settings enable email-based features such as password reset.

**All SMTP parameters are optional.** If not configured, email features will be disabled.

**Configuration**:
```yaml
environment:
  - NETVISOR_SMTP_RELAY=smtp.gmail.com:587
  - NETVISOR_SMTP_USERNAME=your-email@gmail.com
  - NETVISOR_SMTP_PASSWORD=your-app-password
  - NETVISOR_SMTP_EMAIL=netvisor@yourdomain.com
```

## UI Configuration

The UI automatically uses the hostname and port from your browser's address bar to reach the API.

**No configuration needed** for standard deployments where UI and API are on the same domain.

### Advanced: API on Different Domain

If your API server is on a different hostname than where the UI is served (uncommon):

Rebuild the Docker image with build arguments:

```bash
docker build \
  --build-arg PUBLIC_SERVER_HOSTNAME=api.example.com \
  --build-arg PUBLIC_SERVER_PORT=8080 \
  -f backend/Dockerfile \
  -t netvisor-server:custom \
  .
```

Then use your custom image in docker-compose:

```yaml
netvisor-server:
  image: netvisor-server:custom
  # ... rest of config
```

## OIDC Setup

NetVisor supports OpenID Connect (OIDC) for enterprise authentication with providers like Authentik, Keycloak, Auth0, Okta, and others.

### Server Configuration

Add these environment variables to your server configuration:

```yaml
environment:
  # Required OIDC settings
  - NETVISOR_OIDC_ISSUER_URL=https://your-provider.com/application/o/netvisor/
  - NETVISOR_OIDC_CLIENT_ID=your-client-id
  - NETVISOR_OIDC_CLIENT_SECRET=your-client-secret
  - NETVISOR_OIDC_REDIRECT_URL=https://auth.example.com/callback
  - NETVISOR_OIDC_PROVIDER_NAME=Authentik
```

### Parameter Details

| Parameter | Environment Variable | Description |
|-----------|---------------------|-------------|
| **Issuer URL** | `NETVISOR_OIDC_ISSUER_URL` | Your OIDC provider's issuer URL (ends in `/`) |
| **Client ID** | `NETVISOR_OIDC_CLIENT_ID` | OAuth2 client ID from your provider |
| **Client Secret** | `NETVISOR_OIDC_CLIENT_SECRET` | OAuth2 client secret from your provider |
| **Redirect URL** | `NETVISOR_OIDC_REDIRECT_URL` | URL provider redirects to after auth |
| **Provider Name** | `NETVISOR_OIDC_PROVIDER_NAME` | Display name shown in UI (e.g., "Authentik", "Keycloak") |

### Provider Configuration

**Callback URL**: Configure this in your OIDC provider:
```
http://your-netvisor-domain:60072/api/auth/oidc/callback
```

Or with HTTPS:
```
https://your-netvisor-domain/api/auth/oidc/callback
```

**Required scopes**:
- `openid` - OIDC standard
- `email` - For user email address
- `profile` - For user display name (optional)

### Example: Authentik

1. **Create Application** in Authentik:
   - Name: NetVisor
   - Provider: OAuth2/OpenID Provider

2. **Configure Provider**:
   - Redirect URI: `http://netvisor.local:60072/api/auth/oidc/callback`
   - Scopes: `openid email profile`
   - Client Type: Confidential
   - Copy Client ID and Client Secret

3. **Set NetVisor Environment Variables**:
```yaml
environment:
  - NETVISOR_OIDC_ISSUER_URL=https://authentik.company.com/application/o/netvisor/
  - NETVISOR_OIDC_CLIENT_ID=ABC123DEF456
  - NETVISOR_OIDC_CLIENT_SECRET=xyz789uvw012
  - NETVISOR_OIDC_REDIRECT_URL=https://auth.example.com/callback
  - NETVISOR_OIDC_PROVIDER_NAME=Authentik
```

4. **Restart server** and test login

## Session Security

### Secure Cookies

**Important**: Enable secure cookies when running NetVisor behind HTTPS.

```yaml
environment:
  - NETVISOR_USE_SECURE_SESSION_COOKIES=true
```

**When to enable**:
- Behind a reverse proxy with TLS (Nginx, Traefik, Caddy)
- Using a domain with HTTPS
- Production deployments

**When to disable** (default):
- Internal networks without HTTPS
- Development environments
- Accessing via IP address without TLS

**Effect**:
- `true`: Cookies marked as Secure, only sent over HTTPS
- `false`: Cookies sent over HTTP and HTTPS

## Environment Files

For easier management, use `.env` files:

**Create `.env`**:
```bash
# Database
NETVISOR_DATABASE_URL=postgresql://postgres:password@db:5432/netvisor

# Server
NETVISOR_SERVER_PORT=60072
NETVISOR_SERVER_PUBLIC_URL=http://your-domain.com:60072
NETVISOR_LOG_LEVEL=info
NETVISOR_USE_SECURE_SESSION_COOKIES=false

# SMTP (optional - for password reset and notifications)
NETVISOR_SMTP_RELAY=smtp.gmail.com:587
NETVISOR_SMTP_USERNAME=your-email@gmail.com
NETVISOR_SMTP_PASSWORD=your-app-password
NETVISOR_SMTP_EMAIL=netvisor@yourdomain.com

# OIDC (optional)
NETVISOR_OIDC_ISSUER_URL=https://auth.example.com/
NETVISOR_OIDC_CLIENT_ID=client_id
NETVISOR_OIDC_CLIENT_SECRET=client_secret
NETVISOR_OIDC_REDIRECT_URL=https://redirect.example.com/callback
NETVISOR_OIDC_PROVIDER_NAME=Authentik

# Daemon
NETVISOR_INTEGRATED_DAEMON_URL=http://172.17.0.1:60073
```

**Reference in docker-compose.yml**:
```yaml
services:
  netvisor-server:
    image: mayanayza/netvisor-server:latest
    env_file:
      - .env
    # ... rest of config
```

---

**Next Steps**: See the [User Guide](USER_GUIDE.md) to learn how to use NetVisor's features.
