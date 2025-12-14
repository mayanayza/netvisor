# Configuration Reference

Complete reference for configuring Scanopy server and daemon components.

## Table of Contents

- [Configuration Priority](#configuration-priority)
- [Daemon Configuration](#daemon-configuration)
- [Server Configuration](#server-configuration)
- [UI Configuration](#ui-configuration)
- [OIDC Setup](#oidc-setup)
- [Session Security](#session-security)
- [Environment Files](#environment-files)

## Configuration Priority

Scanopy uses the following priority order (highest to lowest):

1. **Command-line arguments** (highest priority)
2. **Environment variables**
3. **Configuration file** (daemon only)
4. **Default values** (lowest priority)

Later sources override earlier ones. For example, an environment variable overrides the config file but is overridden by a command-line argument.

## Daemon Configuration

### Configuration Methods

**Command-line arguments**:

```bash
scanopy-daemon --server-url http://192.168.1.100:60072 --api-key YOUR_KEY
```

**Environment variables**:

```bash
export SCANOPY_SERVER_URL=http://192.168.1.100:60072
export SCANOPY_DAEMON_API_KEY=YOUR_KEY
scanopy-daemon
```

**Docker environment**:

```yaml
environment:
  - SCANOPY_SERVER_URL=http://192.168.1.100:60072
  - SCANOPY_DAEMON_API_KEY=YOUR_KEY
```

**Configuration file**:

The daemon automatically creates a config file at:

- **Linux**: `~/.config/scanopy/daemon/config.json`
- **macOS**: `~/Library/Application Support/com.scanopy.daemon/config.json`
- **Windows**: `%APPDATA%\scanopy\daemon\config.json`

The config file stores runtime state (daemon ID, host ID) alongside your settings. Command-line and environment variables take priority over the file.

### Parameter Reference
<!-- DAEMON_CONFIG_TABLE_START -->
| Parameter | CLI Flag | Environment Variable | Config File Key | Default | Description |
|-----------|----------|---------------------|-----------------|---------|-------------|
| **Server URL** | `--server-url` | `SCANOPY_SERVER_URL` | `server_url` | `http://127.0.0.1:60072` | URL where the daemon can reach the server |
| **API Key** | `--daemon-api-key` | `SCANOPY_DAEMON_API_KEY` | `api_key` | *Required* | Authentication key for daemon (generated via UI) |
| **Mode** | `--mode` | `SCANOPY_MODE` | `mode` | Push | Select whether the daemon will Pull work from the server or have work Pushed to it. If set to Push, you will need to ensure that network you are deploying the daemon on can be reached by the server by opening/forwarding the port to the daemon. If set to Pull, no port opening/forwarding is needed |
| **Network ID** | `--network-id` | `SCANOPY_NETWORK_ID` | `network_id` | *Auto-assigned* | UUID of the network to scan |
| **Daemon URL** | `--daemon-url` | `SCANOPY_DAEMON_URL` | `daemon_url` | detected IP + Daemon Port | Public URL where server can reach daemon. Defaults to auto-detected IP + Daemon Port if not set |
| **Daemon Port** | `--daemon-port` or `-p` | `SCANOPY_DAEMON_PORT` | `port` | `60073` | Port for daemon to listen on |
| **Bind Address** | `--bind-address` | `SCANOPY_BIND_ADDRESS` | `bind_address` | `0.0.0.0` | IP address to bind daemon to |
| **Daemon Name** | `--name` | `SCANOPY_NAME` | `name` | `scanopy-daemon` | Name for this daemon |
| **Log Level** | `--log-level` | `SCANOPY_LOG_LEVEL` | `log_level` | `info` | Logging verbosity |
| **Heartbeat Interval** | `--heartbeat-interval` | `SCANOPY_HEARTBEAT_INTERVAL` | `heartbeat_interval` | `30` | Seconds between heartbeat updates / work requests (for daemons in pull mode) to server |
| **Concurrent Scans** | `--concurrent-scans` | `SCANOPY_CONCURRENT_SCANS` | `concurrent_scans` | *Auto* | Maximum parallel host scans |
| **Allow Self-Signed Certificates** | `--allow-self-signed-certs` | `SCANOPY_ALLOW_SELF_SIGNED_CERTS` | `allow_self_signed_certs` | *None* | Allow self-signed certs for daemon -> server connections |
| **Docker Proxy** | `--docker-proxy` | `SCANOPY_DOCKER_PROXY` | `docker_proxy` | *None* | Optional proxy for Docker API. Can use both non-SSL and SSL proxy; SSL proxy requires additional SSL config vars |
| **Docker SSL Proxy Cert Path** | `--docker-proxy-ssl-cert` | `SCANOPY_DOCKER_PROXY_SSL_CERT` | `docker_proxy_ssl_cert` | *None* | Path to SSL certificate if using a docker proxy with SSL |
| **Docker SSL Proxy Key Path** | `--docker-proxy-ssl-key` | `SCANOPY_DOCKER_PROXY_SSL_KEY` | `docker_proxy_ssl_key` | *None* | Path to SSL private key if using a docker proxy with SSL |
| **Docker SSL Proxy Chain Path** | `--docker-proxy-ssl-chain` | `SCANOPY_DOCKER_PROXY_SSL_CHAIN` | `docker_proxy_ssl_chain` | *None* | Path to SSL chain if using a docker proxy with SSL |
<!-- DAEMON_CONFIG_TABLE_END -->
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
scanopy-daemon --concurrent-scans 10

# Environment
export SCANOPY_CONCURRENT_SCANS=10

# Docker
environment:
  - SCANOPY_CONCURRENT_SCANS=10
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
  - SCANOPY_SERVER_PORT=60072
  - DATABASE_URL=postgresql://postgres:password@db:5432/scanopy
```

**Command-line** (for binary builds):

```bash
./scanopy-server --port 60072 --database-url postgresql://...
```

### Parameter Reference

| Parameter | CLI Flag | Environment Variable | Default | Description |
|-----------|----------|---------------------|---------|-------------|
| **Server Public URL** | `--public-url` | `SCANOPY_PUBLIC_URL` | `http://localhost:60072` | Public URL for webhooks, email links, etc |
| **Server Port** | `--server-port` | `SCANOPY_SERVER_PORT` | `60072` | Port for server to listen on |
| **Database URL** | `--database-url` | `SCANOPY_DATABASE_URL` | *Required* | PostgreSQL connection string |
| **Log Level** | `--log-level` | `SCANOPY_LOG_LEVEL` | `info` | Logging verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| **Secure Cookies** | `--use-secure-session-cookies` | `SCANOPY_USE_SECURE_SESSION_COOKIES` | `false` | Enable HTTPS-only cookies |
| **Integrated Daemon URL** | `--integrated-daemon-url` | `SCANOPY_INTEGRATED_DAEMON_URL` | `http://172.17.0.1:60073` | URL to reach daemon in default docker compose |
| **Disable Registration** | `--disable-registration` | `SCANOPY_DISABLE_REGISTRATION` | `false` | Disable new user registration |
| **SMTP Username** | `--smtp-username` | `SCANOPY_SMTP_USERNAME` | - | SMTP username for email features (password reset, notifications) |
| **SMTP Password** | `--smtp-password` | `SCANOPY_SMTP_PASSWORD` | - | SMTP password for email authentication |
| **SMTP Relay** | `--smtp-relay` | `SCANOPY_SMTP_RELAY` | - | SMTP server address (e.g., `smtp.gmail.com`) |
| **SMTP Email** | `--smtp-email` | `SCANOPY_SMTP_EMAIL` | - | Sender email address for outgoing emails |
| **Client IP Source** | `--client-ip-source` | `SCANOPY_CLIENT_IP_SOURCE` | - | Source of IP address from request headers, used to log accurate IP address in auth logs while using a reverse proxy. Refer to [axum-client-ip](https://github.com/imbolc/axum-client-ip?tab=readme-ov-file#configurable-vs-specific-extractors) docs for values you can set. |

### Integrated Daemon URL

The integrated daemon runs in a separate container and needs to reach the server. The default assumes Docker's bridge network gateway is `172.17.0.1`.

**Check your bridge gateway**:

```bash
docker network inspect bridge | grep Gateway
```

**If different**, update in docker-compose.yml:

```yaml
environment:
  - SCANOPY_INTEGRATED_DAEMON_URL=http://YOUR_GATEWAY_IP:60073
```

### SMTP Configuration

SMTP settings enable email-based features such as password reset.

**All SMTP parameters are optional.** If not configured, email features will be disabled.

**Configuration**:

```yaml
environment:
  - SCANOPY_SMTP_RELAY=smtp.gmail.com:587
  - SCANOPY_SMTP_USERNAME=your-email@gmail.com
  - SCANOPY_SMTP_PASSWORD=your-app-password
  - SCANOPY_SMTP_EMAIL=scanopy@yourdomain.com
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
  -t scanopy-server:custom \
  .
```

Then use your custom image in docker-compose:

```yaml
scanopy-server:
  image: scanopy-server:custom
  # ... rest of config
```

## OIDC Setup

Scanopy supports OpenID Connect (OIDC) for enterprise authentication with providers like Authentik, Keycloak, Auth0, Okta, PocketID, and others.

### Quick Start

1. Copy `oidc.toml.example` to `oidc.toml`
2. Configure your provider settings (see examples below)
3. Mount the file in docker-compose (see [Docker Compose Setup](#oidc-with-docker-compose))
4. Restart the server

### Configuration File Format

```toml
[[oidc_providers]]
name = "Provider Name"           # Display name in UI
slug = "provider-slug"           # Used in callback URL (lowercase, no spaces)
logo = "https://..."             # Optional: logo URL for UI
issuer_url = "https://..."       # Provider's OIDC issuer URL
client_id = "your-client-id"
client_secret = "your-client-secret"
```

You can configure multiple providers by adding multiple `[[oidc_providers]]` sections.

### Callback URL Format

Configure this URL in your OIDC provider's redirect/callback settings:

```
http://your-scanopy-domain:60072/api/auth/oidc/{slug}/callback
```

Replace `{slug}` with the slug value from your oidc.toml. For example, if `slug = "authentik"`:

```
http://scanopy.local:60072/api/auth/oidc/authentik/callback
```

**Required scopes**: `openid`, `email`, `profile` (profile is optional but recommended)

### OIDC with Docker Compose

Add the following volume mount to your `scanopy-server` service:

```yaml
services:
  scanopy-server:
    image: mayanayza/scanopy-server:latest
    volumes:
      - ./oidc.toml:/oidc.toml:ro
    # ... rest of config
```

### Provider-Specific Examples

#### Authentik

1. **Create Application** in Authentik Admin → Applications → Create:
   - Name: `Scanopy`
   - Slug: `scanopy`
   - Provider: Create a new OAuth2/OpenID Provider

2. **Configure Provider**:
   - Name: `Scanopy OIDC`
   - Authorization flow: `default-provider-authorization-implicit-consent`
   - Client type: `Confidential`
   - Redirect URIs: `http://your-scanopy:60072/api/auth/oidc/authentik/callback`
   - Copy the Client ID and Client Secret

3. **Find your Issuer URL**:
   - Go to Providers → your provider → OpenID Configuration Issuer
   - Usually: `https://auth.yourdomain.com/application/o/scanopy/`
   - **Important**: Remove trailing slash if present (see [Common Issues](#common-oidc-issues))

4. **Configure oidc.toml**:

```toml
[[oidc_providers]]
name = "Authentik"
slug = "authentik"
logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/authentik.svg"
issuer_url = "https://auth.yourdomain.com/application/o/scanopy"
client_id = "your-client-id"
client_secret = "your-client-secret"
```

#### Keycloak

1. **Create Client** in Keycloak Admin → Clients → Create:
   - Client ID: `scanopy`
   - Client type: `OpenID Connect`
   - Client authentication: `On`

2. **Configure Client Settings**:
   - Valid redirect URIs: `http://your-scanopy:60072/api/auth/oidc/keycloak/callback`
   - Web origins: `http://your-scanopy:60072`

3. **Get Credentials**:
   - Go to Credentials tab
   - Copy Client Secret

4. **Configure oidc.toml**:

```toml
[[oidc_providers]]
name = "Keycloak"
slug = "keycloak"
logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/keycloak.svg"
issuer_url = "https://keycloak.yourdomain.com/realms/your-realm"
client_id = "scanopy"
client_secret = "your-client-secret"
```

#### PocketID

1. **Create OIDC Client** in PocketID:
   - Go to OIDC Clients → Add Client
   - Name: `Scanopy`
   - Callback URLs: `http://your-scanopy:60072/api/auth/oidc/pocketid/callback`

2. **Copy Credentials**:
   - Client ID
   - Client Secret

3. **Configure oidc.toml**:

```toml
[[oidc_providers]]
name = "PocketID"
slug = "pocketid"
logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pocketid.svg"
issuer_url = "https://pocketid.yourdomain.com"
client_id = "your-client-id"
client_secret = "your-client-secret"
```

#### Auth0

1. **Create Application** in Auth0 Dashboard → Applications → Create:
   - Type: `Regular Web Application`
   - Name: `Scanopy`

2. **Configure Application Settings**:
   - Allowed Callback URLs: `http://your-scanopy:60072/api/auth/oidc/auth0/callback`
   - Allowed Web Origins: `http://your-scanopy:60072`

3. **Configure oidc.toml**:

```toml
[[oidc_providers]]
name = "Auth0"
slug = "auth0"
logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/auth0.svg"
issuer_url = "https://your-tenant.auth0.com"
client_id = "your-client-id"
client_secret = "your-client-secret"
```

#### Okta

1. **Create App Integration** in Okta Admin → Applications → Create:
   - Sign-in method: `OIDC - OpenID Connect`
   - Application type: `Web Application`

2. **Configure Settings**:
   - Sign-in redirect URIs: `http://your-scanopy:60072/api/auth/oidc/okta/callback`
   - Sign-out redirect URIs: `http://your-scanopy:60072`

3. **Configure oidc.toml**:

```toml
[[oidc_providers]]
name = "Okta"
slug = "okta"
logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/okta.svg"
issuer_url = "https://your-org.okta.com"
client_id = "your-client-id"
client_secret = "your-client-secret"
```

### Common OIDC Issues

#### "Unexpected issuer URI" error

```
Failed to generate auth URL: Validation error: unexpected issuer URI
`https://auth.example.com/app/` (expected `https://auth.example.com/app`)
```

**Cause**: Trailing slash mismatch between your config and what the provider returns.

**Solution**: Try both with and without trailing slash in `issuer_url`. The value must exactly match what your provider returns in its `.well-known/openid-configuration`.

To check what your provider expects:
```bash
curl https://your-provider/.well-known/openid-configuration | jq .issuer
```

#### "Invalid redirect URI" error

**Cause**: The callback URL in your provider doesn't match what Scanopy sends.

**Solution**: Ensure the redirect URI in your provider exactly matches:
```
http://your-scanopy:60072/api/auth/oidc/{slug}/callback
```

Common mistakes:
- Wrong protocol (http vs https)
- Wrong port
- Wrong slug (must match oidc.toml)
- Missing `/callback` at the end

#### OIDC button not appearing in UI

**Causes**:
1. oidc.toml file not mounted in Docker
2. oidc.toml has syntax errors
3. Server not restarted after adding config

**Solution**:
1. Verify the volume mount exists in docker-compose.yml
2. Validate TOML syntax (use a TOML validator)
3. Restart with `docker compose restart scanopy-server`
4. Check server logs: `docker logs scanopy-server`

#### "Connection refused" when authenticating

**Cause**: Scanopy server can't reach your OIDC provider.

**Solutions**:
1. Ensure the provider URL is reachable from the server container
2. If provider is internal, ensure Docker can resolve the hostname
3. Add provider to Docker's extra_hosts if needed:
   ```yaml
   extra_hosts:
     - "auth.internal:192.168.1.100"
   ```

## Session Security

### Secure Cookies

**Important**: Enable secure cookies when running Scanopy behind HTTPS.

```yaml
environment:
  - SCANOPY_USE_SECURE_SESSION_COOKIES=true
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
SCANOPY_DATABASE_URL=postgresql://postgres:password@db:5432/scanopy

# Server
SCANOPY_SERVER_PORT=60072
SCANOPY_SERVER_PUBLIC_URL=http://your-domain.com:60072
SCANOPY_LOG_LEVEL=info
SCANOPY_USE_SECURE_SESSION_COOKIES=false

# SMTP (optional - for password reset and notifications)
SCANOPY_SMTP_RELAY=smtp.gmail.com:587
SCANOPY_SMTP_USERNAME=your-email@gmail.com
SCANOPY_SMTP_PASSWORD=your-app-password
SCANOPY_SMTP_EMAIL=scanopy@yourdomain.com

# Daemon
SCANOPY_INTEGRATED_DAEMON_URL=http://172.17.0.1:60073
```

**Reference in docker-compose.yml**:

```yaml
services:
  scanopy-server:
    image: mayanayza/scanopy-server:latest
    env_file:
      - .env
    # ... rest of config
```

---

**Next Steps**: See the [User Guide](USER_GUIDE.md) to learn how to use Scanopy's features.
