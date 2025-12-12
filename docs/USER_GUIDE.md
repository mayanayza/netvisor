# User Guide

Complete guide to using NetVisor's features for network discovery, organization, and visualization.

## Table of Contents

- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [Organizations](#organizations)
- [Navigation](#navigation)
- [Networks](#networks)
- [Hosts](#hosts)
- [Services](#services)
- [Subnets](#subnets)
- [Groups](#groups)
- [Daemons](#daemons)
- [API Keys](#api-keys)
- [Discovery](#discovery)
- [Tags](#tags)
- [Topology Visualization](#topology-visualization)
- [Multi-VLAN Setup](#multi-vlan-setup)
- [FAQ](#faq)

## Getting Started

### First Time Setup

1. **Access the UI** at `http://<your-server-ip>:60072`

2. **Create your account**:
   - Enter an email address
   - Create a password
   - Click **Register**
   - Alternatively, use OIDC authentication (see [Authentication](#authentication))

<p align="center">
  <img src="../media/registration.png" width="400" alt="Registration Screen">
</p>

3. **Onboard**: 
    - Select the name of your organization and network
    - Decide whether NetVisor should create baseline data for your first network (recommended)
  
4. **Create and deploy your first daemon**
    - Go to the Daemons tab to create a Daemon. If you are using the Community edition with the default Docker Compose, a daemon is enabled by default.
    - Install it on the host of your choice
       - If you are running the daemon on a network which is remote from the server, you will need to open and forward a port if using the Daemon in Push mode. You can also use Push mode if you prefer to not do any port forwarding.
       - Take into consideration your [multi-vlan strategy](https://github.com/netvisor-io/netvisor/blob/main/docs/MULTI_VLAN_GUIDE.md)
    - The daemon will automatically run discovery

5. **Monitor discovery**: Switch to **Discover > Sessions** to watch the scan progress

<p align="center">
  <img src="../media/first_discovery.png" width="600" alt="First Discovery">
</p>

5. **View results**: Once complete, navigate to **Topology** to see your network diagram

## Authentication

NetVisor supports two authentication methods:

### Email & Password

Standard authentication with email and password.

**Updating credentials**: Go to **Account** in sidebar to change your email or password.

### OIDC (OpenID Connect)

NetVisor supports OIDC authentication for enterprise identity providers like Authentik, Keycloak, Auth0, Okta, and others.

**Setup**: OIDC must be configured by the server administrator. See [CONFIGURATION.md](CONFIGURATION.md#oidc-setup) for setup instructions.

**Linking OIDC**: If OIDC is enabled, you can link it to your existing account:
1. Go to **Account Settings** (user icon in top right)
2. Click **Link** under your OIDC provider
3. Complete the authentication flow
4. Your account is now linked

**Unlinking**: You can unlink OIDC at any time, but you'll need to have a password set first.

## Organizations

Organizations are the top-level container for users and networks. Every user belongs to exactly one organization.

### Organization Roles

These permission levels control what users can do:

**Owner**
- Everything Admins can do
- Manage organization settings
- Invite Admins

**Admin**
- Everything Members can do
- View other Admins
- Invite Members
- Remove Members

**Member**
- Everything Visualizers can do
- Create and edit networks, hosts, services
- Run discovery sessions
- Manage daemons and API keys
- View other members
- Invite Visualizers
- Remove Visualizers

**Visualizer**
- View topology diagrams

### Managing Users

**Inviting users**:
1. Navigate to **Manage > Users**
2. Click **"Invite User"**
3. Select the permission level
4. Click **"Generate Link"** to create an invite link
5. Share the invite URL with the new user
6. They'll register and automatically join your organization

**Viewing users**:
- See all organization members in **Manage > Users**
- View each user's role, authentication method, and join date

**Removing users** (Owner only):
- Click the delete icon on a user card
- You cannot delete yourself
- You cannot delete the only Owner

<p align="center">
  <img src="../media/organization_users.png" width="800" alt="Organization Users">
</p>

### Organization Settings

**Viewing organization** (Owner only):
- Navigate to **Manage > Organization** to view organization name and plan information

**Note**: Organizations are automatically created during registration and cannot be manually created or transferred.

## Navigation

The NetVisor UI is organized into three main sections:

### Sidebar

#### Topology

Interactive network visualization showing hosts, services, subnets, and their connections.

#### Discover

**Sessions**
- Monitor active discovery scans in real-time
- View completed discovery history
- See scan progress, duration, and results

**Scheduled**
- Create and manage scheduled discoveries
- Configure automatic network scanning
- Set custom cron schedules

#### Manage

**Networks** - Organize resources by network environment  
**Hosts** - View and manage discovered devices  
**Services** - Browse all detected services  
**Subnets** - Configure network segments  
**Groups** - Create logical service groupings  
**Daemons** - Manage discovery agents  
**API Keys** - Control daemon authentication  
**Users** - Manage organization members  

#### Settings

**Organization** - View and edit organization settings (only Owners)
**Account** - View and edit account settings

## Networks

Networks are the primary organizational unit in NetVisor. Each network represents a distinct environment with its own hosts, services, and topology.

### What Networks Are For

- Separating production, staging, and home environments
- Organizing networks by physical location
- Managing multi-tenant deployments
- Grouping related infrastructure

### Network Properties

- **Name**: Display name for the network
- **Description**: Optional notes about the network's purpose
- **Daemons**: Which daemons scan this network
- **Hosts**: Number of discovered hosts
- **Services**: Number of detected services

### Managing Networks

**Creating a network**:
1. Navigate to **Manage > Networks**
2. Click **"Create Network"**
3. Enter name and optional description
4. Deploy a daemon to scan it

**Switching networks**: Networks are selected via the topology options panel or when creating discoveries.

**Deleting a network**: Click the delete icon on the network card. This removes all associated hosts, services, and topology data.

<p align="center">
  <img src="../media/networks_tab.png" width="800" alt="Networks Tab">
</p>

## Hosts

Hosts represent physical or virtual devices on your network. They are automatically discovered during network scans.

### Host Properties

- **Name**: Hostname or custom name
- **IP Addresses**: All network interfaces
- **MAC Addresses**: Hardware addresses for each interface
- **Interfaces**: Network connections and subnet membership
- **Services**: Services running on the host
- **Virtualization**: Container or VM relationships (if detected)

### Managing Hosts

**Viewing hosts**:
- Navigate to **Manage > Hosts**
- Filter by network, service type, or search
- Click a host to see detailed information

**Editing a host**:
1. Click on a host card
2. Modify properties in the detail panel
3. Add/remove interfaces or services
4. Save changes

**Creating a host manually**:
1. Click **"Create Host"**
2. Provide name and at least one interface
3. Add services as needed
4. Save

**Deleting a host**: Click the delete icon. This removes the host and all its interfaces and services.

<p align="center">
  <img src="../media/hosts_tab.png" width="800" alt="Hosts Tab">
</p>

### Consolidating Hosts

When a device appears on multiple VLANs or through different discovery methods, it may be discovered as separate hosts. Use consolidation to merge them.

**How to consolidate**:
1. Select a host to keep (primary)
2. Click **"Consolidate"**
3. Select the duplicate host(s) to merge
4. Review the consolidated result
5. Confirm the merge

The primary host will gain all interfaces, services, and properties from the merged hosts.

### Unclaimed Open Ports

Any ports that the host has open which were not used to match a specific service will be assigned to an "Unclaimed Open Ports" placeholder service. You can transfer ports from this service to other by selecting the port bindings, then clicking "Transfer Ports" on the service you want to transfer them to.

### Host Virtualization

If a host runs Proxmox or Docker, NetVisor tracks which VMs or containers run on it.

**Virtualization managers detected**:
- **Proxmox**: Links VMs and LXC containers to the Proxmox service running on the host
- **Docker**: Links containers to the Docker service running on the host

This relationship is displayed in the topology and host details.

## Services

Services represent applications or servers running on hosts. NetVisor automatically detects 50+ common services.

### Service Properties

- **Name**: Service display name
- **Definition**: Service type (e.g., "Plex", "Home Assistant")
- **Category**: Classification (Media, Infrastructure, Development, etc.)
- **Host**: Which host runs this service
- **Bindings**: Ports and interfaces the service listens on
- **Confidence**: Detection confidence (System, High, Medium, Low)

### Service Categories

Services are organized into categories for filtering and organization:

**Infrastructure**
- NetworkCore, NetworkAccess, NetworkSecurity
- DNS, VPN, ReverseProxy

**Server Services**
- Storage, Media, HomeAutomation, Virtualization
- Backup, FileSharing

**Applications**
- Web, Database, Development, Dashboard
- Monitoring, MessageQueue, Collaboration
- IdentityAndAccess, Communication

**Devices**
- Workstation, Mobile, IoT, Printer

**Other**
- AdBlock, Custom, Unknown

### Managing Services

**Viewing services**:
- Navigate to **Manage > Services**
- Filter by category, host, or network
- Click a service for details

**Editing a service**:
1. Click on a service card
2. Modify name, bindings, or properties
3. Save changes

**Creating a service manually**:
1. Navigate to a host's detail view
2. Go to the **Services** tab
3. Click **"Add Service"**
4. Select service type and configure bindings
5. Save

**Deleting a service**: Click the delete icon on the service card.

<p align="center">
  <img src="../media/services_tab.png" width="800" alt="Services Tab">
</p>

## Subnets

Subnets represent network segments and are used to organize hosts in the topology.

### Subnet Properties

- **CIDR**: Network address and mask (e.g., `192.168.1.0/24`)
- **Name**: Custom name or defaults to CIDR
- **Description**: Optional notes about the subnet's purpose
- **Type**: Network classification (LAN, Docker Bridge, Internet, Remote, etc.)

### Subnet Types

NetVisor automatically detects subnet types during discovery:

**Physical Networks**
- **LAN**: Local area networks
- **WiFi**: Wireless networks  
- **IoT**: IoT device networks
- **Guest**: Guest networks

**Infrastructure**
- **Gateway**: Gateway interfaces
- **VPN Tunnel**: VPN connections
- **DMZ**: Demilitarized zones
- **Management**: Management networks

**Virtual Networks**
- **Docker Bridge**: Docker container networks

**Special Types**
- **Internet**: Organizational subnet for public services (uses 0.0.0.0/0)
- **Remote**: Organizational subnet for remote hosts (uses 0.0.0.0/0)

### Organizational Subnets

Subnets with CIDR `0.0.0.0/0` don't represent real networks—they're organizational containers:

**Internet Subnet**: For public services
- Public DNS servers (1.1.1.1, 8.8.8.8)
- Cloud services
- External APIs

**Remote Subnet**: For non-local hosts
- Mobile devices
- Remote offices connected via VPN
- Hosts on friend's networks

### Managing Subnets

**Viewing subnets**:
- Navigate to **Manage > Subnets**
- See all subnets across networks
- Filter by network or type

**Editing a subnet**:
1. Click on a subnet card
2. Modify name, description, or type
3. Save changes

**Creating a subnet**:
1. Click **"Create Subnet"**
2. Enter CIDR and name
3. Select type
4. Save

**Deleting a subnet**: Click the delete icon. Hosts on the subnet remain but lose subnet association.

<p align="center">
  <img src="../media/subnets_tab.png" width="800" alt="Subnets Tab">
</p>

## Groups

Groups create logical connections between services and hosts for topology visualization.

### Group Types

**Hub and Spoke**
- Central service with connections to multiple others
- Example: API gateway connected to microservices
- Example: Database accessed by multiple applications

**Path**
- Linear flow through services
- Example: User → Reverse Proxy → Web App → Database
- Example: Client → VPN → Internal Services

### Group Properties

- **Name**: Display name
- **Type**: Hub and Spoke or Path
- **Services**: Which services/hosts participate
- **Color**: Visual styling in topology (optional)

### What Groups Do

Groups affect how your topology is displayed:
- Add edges between services to show relationships
- Create visual groupings
- Help document application architectures
- Organize complex network structures

### Managing Groups

**Creating a group**:
1. Navigate to **Manage > Groups**
2. Click **"Create Group"**
3. Select type (Hub and Spoke or Path)
4. Choose the central service (Hub and Spoke) or order services (Path)
5. Add related services
6. Save

**Editing a group**:
1. Click on a group card
2. Modify services or reorder (Path groups)
3. Save changes

**Deleting a group**: Click the delete icon. This only removes the logical grouping—services and hosts remain.

<p align="center">
  <img src="../media/groups_tab.png" width="800" alt="Groups Tab">
</p>

### Use Cases

**Web application stack**:
```
Hub: Database
Spokes: Web Server, Background Workers, Admin Panel
```

**Reverse proxy flow**:
```
Path: Internet → Cloudflare → Traefik → Application
```

## Daemons

Daemons are lightweight agents that perform network discovery.

### Daemon Configuration

See [CONFIGURATION.md](CONFIGURATION.md#daemon-configuration) for a full list of daemon config properties.

### Daemon Capabilities

Each daemon reports its capabilities:

**Docker Socket Access**
- **True**: Can discover Docker containers
- **False**: Cannot access Docker socket

**Interfaced Subnets**
- Lists which subnets the daemon has network interfaces with
- The daemon will scan these subnets by default during network discovery

### Managing Daemons

**Viewing daemons**:
- Navigate to **Manage > Daemons**
- See all daemons and their capabilities
- Check last seen timestamps

**Creating a daemon**:
1. Click **"Create Daemon"**
2. Select target network
3. Click **"Generate Key"** to create API key
4. Copy the Docker Compose or binary command
5. Run it on your target host

See [INSTALLATION.md](INSTALLATION.md#additional-daemons) for deployment instructions.

**Updating daemon properties**: 

You can update all daemon properties after creation; however, you'll need to restart the daemon for property updates to take effect.

Name, Mode, and URL will be propagated to the server if changed. All other properties are local to the daemon and not stored on the server.

To update daemon capabilities (docker socket integration and interfaced subnets), you'll need to run a SelfReport discovery to report the new capabilities to the server.

**Deleting a daemon**: Click the delete icon. You'll also need to uninstall the daemon from the host it's running on.

<p align="center">
  <img src="../media/daemons_tab.png" width="800" alt="Daemons Tab">
</p>

**Important**: Deleting a daemon does NOT delete discovered data. Hosts, services, and topology remain until explicitly deleted.

## API Keys

API keys authenticate daemons to the server. Each daemon requires one API key.

### API Key Properties

- **Name**: Custom identifier for the key
- **Network**: Which network this key grants access to
- **Created**: When the key was generated
- **Last Used**: Timestamp of last authentication
- **Expires At**: Optional expiration date
- **Enabled**: Whether the key is currently active

### Managing API Keys

**Viewing API keys**:
- Navigate to **Manage > API Keys**
- See all keys and their usage status

**Creating an API key**:
1. Go to **Manage > Daemons**
2. Click **"Create Daemon"**
3. Click **"Generate Key"**
4. The key is automatically created and assigned to the network

Alternatively:
1. Go to **Manage > API Keys**
2. Click **"Create API Key"**
3. Select target network
4. Set optional expiration
5. Save and copy the key (it won't be shown again)

**Disabling an API key**:
1. Click on the key card
2. Toggle **"Enabled"** to off
3. Save

Disabled keys cannot authenticate, but can be re-enabled later.

**Deleting an API key**: Click the delete icon. Any daemons using this key will stop authenticating and stop working.

<p align="center">
  <img src="../media/api_keys_tab.png" width="800" alt="API Keys Tab">
</p>

### Security Best Practices

- Create separate API keys for each daemon
- Use expiration dates for temporary deployments
- Disable unused keys rather than deleting them
- Rotate keys periodically for production environments
- Never share keys in public repositories or logs

## Discovery

Discovery is the process of scanning your network to find hosts and services.

### Discovery Types

**Self-Report**
- Daemon reports its own capabilities
- Identifies Docker socket access
- Lists interfaced subnets
- Runs automatically on daemon startup

**Network Scan**
- Scans IP addresses on configured subnets
- Detects open ports
- Identifies services via pattern matching
- Performs reverse DNS lookups
- Collects MAC addresses (for directly connected subnets)

**Docker**
- Connects to Docker socket on daemon's host
- Discovers running containers
- Maps container names and metadata
- Detects containerized services
- Identifies internal Docker networks

### Run Types

**AdHoc (On Demand)**
- Manual execution only
- Use for testing or one-time scans
- Triggered from **Discover > Sessions**

**Scheduled (Automatic)**
- Runs on a cron schedule
- Default: Every 24 hours (`0 0 */1 * * *`)
- Enable/disable without deleting

### Creating a Discovery

1. Navigate to **Discover > Scheduled**
2. Click **"Create Discovery"**
3. **Details**:
   - Enter a name (e.g., "Daily Network Scan")
   - Select the daemon to execute the discovery
4. **Type**:
   - Choose discovery type (Network, Docker, or Self-Report)
   - For Network: Select subnets to scan. You can add subnets that the daemon doesn't have a direct interface with, and it will try to reach IP addresses on that subnet as well.
   - For Docker/Self-Report: Automatically uses daemon's host
5. **Schedule** (optional):
   - Choose AdHoc or Scheduled
   - For Scheduled: Set cron schedule or use preset intervals
6. Save

### Running a Discovery

**Manual execution**:
1. Navigate to **Discover > Sessions**
2. Find your discovery in the scheduled list
3. Click the **"Run"** button
4. Monitor progress in real-time

**Scheduled execution**:
- Scheduled discoveries run automatically at their configured time
- View the "Last Run" timestamp in the scheduled discoveries list

### Monitoring Discovery

**Real-time progress**:
- Navigate to **Discover > Sessions**
- Active scans show live progress updates
- See scanned count vs. discovered count
- Watch as hosts and services are found

**Discovery history**:
- Completed discoveries appear in the history list
- View duration, start/end times, and results
- Filter by daemon or network

<p align="center">
  <img src="../media/discovery_sessions.png" width="800" alt="Discovery Sessions">
</p>

### Discovery Duration

For benchmarking, 1x /24 subnet (256 IP addresses) takes 5-10 minutes to scan in full.

Factors affecting speed:
- Number of IP addresses to scan
- Subnet mask size (smaller masks = more IPs)
- Concurrent scans setting (default: 15)
- Network response times

### Host Naming

When discovering hosts, NetVisor determines names using this priority:

1. Hostname from reverse DNS, if available
2. If **BestService** is set - will use the first named service identified on the host. If **IP** is set, will use the host's IP address
3. If option 2 didn't produce a name, will use the remaining fallback (ie **IP** if **BestService** was set)

Configure this per-discovery in the discovery type settings.

## Tags

Tags provide organization-wide labels for categorizing and filtering entities. Apply tags to hosts, services, subnets, networks, groups, and daemons to create custom taxonomies that work across your entire infrastructure.

### What Tags Are For

- Categorizing infrastructure by environment (production, staging, development)
- Marking criticality levels (critical, high, medium, low)
- Identifying ownership (team-a, team-b, contractor)
- Tracking lifecycle status (deprecated, migrating, new)
- Custom organization-specific classifications

### Tag Properties

- **Name**: Display name for the tag (unique within organization)
- **Description**: Optional notes about when to use this tag
- **Color**: Visual color for the tag chip

### Tag Scope

Tags are defined at the **organization level**, meaning:
- The same tag can be applied to entities across all networks
- Tag definitions are shared by all users in the organization
- Deleting a tag removes it from all entities that had it applied

### Managing Tags

**Viewing tags**:
- Navigate to **Manage > Tags**
- See all organization tags with their colors
- Filter and search by name

**Creating a tag**:
1. Navigate to **Manage > Tags**
2. Click **"Create Tag"**
3. Enter name and optional description
4. Select a color
5. Save

**Creating a tag inline**:
1. While editing any entity (host, service, subnet, etc.)
2. Type a new tag name in the tag picker
3. Click **"Create [tag name]"** (requires Admin or Owner role)
4. The tag is created and automatically applied

**Editing a tag**:
1. Click on a tag card
2. Modify name, description, or color
3. Save changes

**Deleting a tag**: Click the delete icon. The tag is removed from all entities that had it applied.

<p align="center">
  <img src="../media/tags_tab.png" width="800" alt="Tags Tab">
</p>

### Applying Tags to Entities

Tags can be applied to any entity that supports them:

**From the entity edit modal**:
1. Open any host, service, subnet, network, group, or daemon
2. Find the **Tags** field
3. Click to open the tag picker
4. Type to filter or select from available tags
5. Press Enter or click to add
6. Save the entity

**Removing tags**:
- Click the **X** on any tag chip to remove it
- Save the entity to persist changes

<p align="center">
  <img src="../media/tag_picker.png" width="500" alt="Tag Picker">
</p>

### Filtering by Tags

Use tags to filter entity lists:

1. Navigate to any entity list (Hosts, Services, Subnets, etc.)
2. Click **"Filters"**
3. Select one or more tags from the Tags filter
4. Items matching **any** selected tag are shown

### Permissions

| Action | Minimum Role |
|--------|-------------|
| View tags | Visualizer |
| Apply/remove tags on entities | Member |
| Create, edit, delete tags | Admin |

### Use Cases

**Environment classification**:
```
Tags: production, staging, development, testing
Apply to: Hosts, Services, Networks
```

**Criticality tracking**:
```
Tags: critical, high-priority, standard, low-priority
Apply to: Hosts, Services
```

**Team ownership**:
```
Tags: platform-team, frontend-team, data-team, external
Apply to: Hosts, Services, Groups
```

**Compliance and auditing**:
```
Tags: pci-scope, hipaa, gdpr, internal-only
Apply to: Hosts, Subnets, Services
```

## Topology Visualization

The topology view generates an interactive diagram of your network structure.

<p align="center">
  <img src="../media/topology_full.png" width="800" alt="Topology visualization">
</p>

### Topology State

Topology will display different states depending on if the underlying data has changed since it was last built. Pressing Rebuild will have different effects depending on topology state.

Rebuilding the graph will reset some user-provided changes, such as node positions and subnet sizes. Edge handles will be preserved when possible, but may also be overwritten as the layout of the graph may need to change depending on entities being added or removed.
<br>

### Auto Rebuild

<p align="center">
  <img src="../media/topology_auto.png" width="800" alt="Topology auto rebuild">
</p>
- Topology will rebuild automatically, regardless of whether rebuilding may change graph layout or remove deleted entities
<br>

### Up to date

<p align="center">
  <img src="../media/topology_fresh.png" width="800" alt="Topology up to date">
</p>
- All data is up to date<br>
- There is usually no reason to rebuild the graph in this state<br>
<br>

### Stale

<p align="center">
  <img src="../media/topology_stale.png" width="800" alt="Topology stale">
</p>
- One or more entities have been added or updated since the visualization was last rebuilt<br>
- Rebuilding the graph will add those entities<br>
<br>

### Conflict

<p align="center">
  <img src="../media/topology_conflict.png" width="800" alt="Topology conflict">
</p>
- One or more entities on the graph have been deleted since it was last rebuilt<br>
- Rebuilding the graph will remove those entities<br>
- The specific entities that will be removed will be displayed in a modal so you can confirm before they are removed.<br>
<br>

### Locked

<p align="center">
  <img src="../media/topology_locked.png" width="800" alt="Topology locked">
</p>
- Other states will not be displayed<br>
- Topology cannot be rebuilt<br>
- Press Lock to enter the locked state<br>
<br>

### Visual Elements

**Subnet Containers**
- Large rectangles grouping hosts by network segment
- Shows subnet name and CIDR
- Can be resized manually

**Interface Nodes**
- Represent network interfaces
- Show services bound to that interface
- Display IP addresses and hostnames

**Services**
- Icons representing detected services
- Show service name and ports

**Edges**
- Lines connecting related nodes
- Different types:
  - Host interfaces
  - Group relationships
  - Docker container links

**Left Zone**
- Optional section within each subnet
- Can display infrastructure services separately
- Customizable title and service categories

### Customization Options

Access the options panel via the button on the right side of the topology view:

<p align="center">
  <img src="../media/topology_options_overview.png" width="800" alt="Topology Options">
</p>

**Visual Options**

*Don't Fade Edges*
- Show all edges at full opacity
- Default behavior fades unselected edges
- Enable for clearer edge visibility and screenshot appearance

*Hide Resize Handles*
- Remove subnet resize handles from corners
- Cleaner screenshot appearance
- Re-enable to adjust subnet sizes

**Docker Options**

*Group Docker Bridges*
- Display all containers on a host in one subnet grouping
- Off: Each Docker bridge gets its own subnet container
- On: All Docker containers grouped under one subnet per host

<p align="center">
  <img src="../media/topology_docker_grouping.png" width="700" alt="Docker Grouping Comparison">
</p>

*Hide VM Provider on Containers*
- Don't indicate the VM provider for containerized services
- Useful when virtualization hierarchy is obvious
- Reduces visual noise

**Left Zone Options**

*Custom Title*
- Change the "Infrastructure" label to your preference
- Examples: "Core Services", "Network", "Foundation"
- Applied to all subnets

*Service Categories*
- Select which categories appear in the left zone
- Default: DNS and ReverseProxy
- Common choices: Add VPN, Monitoring

*Show Gateway in Left Zone*
- Display gateway services in the left zone
- Off: Gateways appear in the main subnet area
- On: Gateways separated in left zone

**Hide Options**

*Hide Ports*
- Don't show port numbers next to services
- Cleaner appearance
- Re-enable to see listening ports

*Service Categories*
- Select categories to completely hide from topology
- More aggressive than filtering
- Use to remove entire classes of services

*Edge Types*
- Hide specific connection types
- Options: Interface, Gateway, Group, Container
- Simplifies complex topologies

### Manual Adjustments

**Node Positioning**
- Click and drag any node to reposition

**Edge Handle**
- Select an edge to show handles (same-colored circle at edge ends)
- Move handles to other locations on node

**Subnet Sizing**
- Drag subnet corners to resize
- Useful for fitting many hosts

### Exporting

Export your topology as a PNG image:

1. Customize your topology as desired
2. Click the **Export** button in the topology header
3. PNG file downloads automatically with timestamp
4. Image includes all current customizations

Use cases:
- Documentation
- Presentations
- Sharing with team members
- Progress tracking

## Multi-VLAN Setup

To map networks across multiple VLANs, deploy additional daemons or select additional subnets in **Discovery > Scheduled**.

### Why Multiple Daemons?

Adding subnets to a scan works, but the daemon isn't guaranteed to be able to reach those subnets depending on your network firewall and other configurations, and it won't be able to get MAC Addresses or Hostnames from DNS.

For isolated VLANs:
- Deploy one daemon per VLAN
- Each daemon scans its local network segment
- Server merges data into unified topology

### Deployment Strategy

**Option 1: Daemon per VLAN (Recommended)**

1. Identify your VLANs:
   - Production (192.168.1.0/24)
   - IoT (192.168.2.0/24)
   - Guest (192.168.3.0/24)

2. Deploy a daemon on each network:
   - Place a host on each VLAN (or use a router/firewall with access)
   - Install daemon following [INSTALLATION.md](INSTALLATION.md#additional-daemons)
   - Configure with appropriate network ID

3. Run discoveries:
   - Each daemon scans its local VLAN
   - Server consolidates results automatically

**Option 2: Configure Subnets Daemon Can Reach**

If your daemon can route to multiple VLANs (e.g., it's on a management network):

1. Create subnets for each VLAN in **Manage > Subnets**
2. Create a Network Scan discovery in **Discover > Scheduled**
3. Select all reachable subnets
4. Run the discovery

**Note**: Without direct interface, the daemon cannot collect MAC addresses or hostnames via DHCP.

### Handling Duplicate Hosts

Devices appearing on multiple VLANs may be discovered as separate hosts. Use the [Consolidate Hosts](#consolidating-hosts) feature to merge them:

1. Identify the duplicate hosts (same device, different IPs)
2. Select the primary host to keep
3. Click **"Consolidate"**
4. Select the duplicate(s) to merge
5. Confirm

The primary host will have interfaces on all VLANs.

## FAQ

### Is IPv6 supported?

Not currently. IPv6 support is planned for future releases:

**Planned features**:
- Collecting and displaying IPv6 addresses during discovery
- Manual entry of IPv6 addresses when editing hosts
- IPv6 connectivity testing for known hosts

**Not planned**:
- Full IPv6 subnet scanning (would take too long for /64 networks)

If you need IPv6 support sooner, [open an issue](https://github.com/netvisor-io/netvisor/issues/new) describing your use case.

### What services can NetVisor discover?

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

For the complete list, see the [service definitions directory](SERVICES.md).

**Service not detected?**
- Report it: [Service detection issue](https://github.com/netvisor-io/netvisor/issues/new?template=service-detection-issue.md)
- Request it: [Missing service](https://github.com/netvisor-io/netvisor/issues/new?template=missing-service-detection.md)
- Contribute: [Service definition guide](contributing.md#adding-service-definitions)

### How do I contribute?

We welcome contributions! See [contributing.md](contributing.md) for:
- Adding service definitions (great first contribution!)
- Reporting bugs
- Requesting features
- Submitting pull requests

Join our [Discord community](https://discord.gg/b7ffQr8AcZ) for help and discussions.

Update `NETVISOR_INTEGRATED_DAEMON_URL` to match if using the integrated daemon.

See [CONFIGURATION.md](CONFIGURATION.md) for more options.

### How do I backup my data?

NetVisor stores all data in PostgreSQL. To backup:

**Docker setup**:
```bash
# Backup
docker exec netvisor-db pg_dump -U postgres netvisor > netvisor_backup.sql

# Restore
docker exec -i netvisor-db psql -U postgres netvisor < netvisor_backup.sql
```

**Manual setup**: Use standard PostgreSQL backup tools (pg_dump, pg_restore).

### How do I reset my password?

Currently, password resets must be done directly in the database:

1. Generate a new password hash using bcrypt
2. Update the `users` table with the new hash
3. Or, ask another Owner to delete and re-invite you

Self-service password reset is planned for a future release.

### Why is my topology empty after discovery?

Check these common issues:

1. **Discovery failed**: View **Discover > Sessions** for errors
2. **Wrong network selected**: Check topology options panel for network filter
3. **All services hidden**: Check if service category filters are too aggressive
4. **No hosts found**: Verify daemon can reach the network

See [INSTALLATION.md](INSTALLATION.md#troubleshooting) for more troubleshooting steps.

---

**Need help?** Join our [Discord](https://discord.gg/b7ffQr8AcZ) or [open an issue](https://github.com/netvisor-io/netvisor/issues/new).
