# Multi-VLAN Deployment Guide

Guide for deploying NetVisor across multiple VLANs and network segments.

## Table of Contents

- [Overview](#overview)
- [When You Need Multiple Daemons](#when-you-need-multiple-daemons)
- [Deployment Strategies](#deployment-strategies)
- [Step-by-Step Setup](#step-by-step-setup)
- [Network Requirements](#network-requirements)

## Overview

NetVisor uses daemons to discover hosts and services. The integrated daemon can scan networks it has direct access to, but isolated VLANs require additional daemons.

```
┌─────────────────────────────────────────────────────────────┐
│                    NetVisor Server                          │
│                   (192.168.1.10:60072)                      │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ VLAN 1        │ │ VLAN 2        │ │ VLAN 3        │
│ Production    │ │ IoT           │ │ Guest         │
│ 192.168.1.0/24│ │ 192.168.2.0/24│ │ 192.168.3.0/24│
│ [Daemon 1]    │ │ [Daemon 2]    │ │ [Daemon 3]    │
└───────────────┘ └───────────────┘ └───────────────┘
```

## When You Need Multiple Daemons

### Single Daemon is Sufficient When:

- All hosts are on the same subnet as the daemon
- You have a management host with routes to all VLANs
- Your firewall allows the daemon to reach all subnets
- You don't need MAC addresses from isolated networks

### Multiple Daemons Required When:

- VLANs are isolated by firewall rules
- You need accurate MAC address collection (requires Layer 2 access)
- Different networks have different security requirements

## Deployment Strategies

### Strategy 1: Daemon Per VLAN (Recommended)

Deploy a lightweight daemon on each VLAN.

**Pros:** Full Layer 2 access (MAC addresses, ARP), no inter-VLAN firewall rules needed, best discovery accuracy

**Cons:** More daemons to manage, requires a host on each VLAN

**Best for:** Production environments, security-conscious deployments

### Strategy 2: Central Daemon with Routing

Use a single daemon on a host that can route to all VLANs.

**Pros:** Single daemon to manage

**Cons:** No MAC address collection for remote subnets, requires firewall rules, Layer 3 only

**Best for:** Small networks, lab environments, quick setup

### Strategy 3: Hybrid Approach

Central daemon for routable networks, dedicated daemons for isolated segments.

## Step-by-Step Setup

### Step 1: Plan Your Deployment

| VLAN | Subnet | Purpose | Daemon Location |
|------|--------|---------|-----------------|
| 1 | 192.168.1.0/24 | Production | netvisor-server host |
| 10 | 192.168.10.0/24 | IoT | IoT management VM |
| 20 | 192.168.20.0/24 | Guest | Guest network AP |

### Step 2: Create Daemon in NetVisor UI

1. Navigate to **Manage > Daemons**
2. Click **"Create Daemon"**
3. Select the target network
4. Choose daemon mode:
   - **Push**: Server initiates scans (daemon must be reachable from server)
   - **Pull**: Daemon polls for work (daemon only needs outbound access to server)
5. Click **"Generate Key"**
6. Copy the installation command

### Step 3: Deploy Daemon

Follow the installation instructions in [INSTALLATION.md - Additional Daemons](INSTALLATION.md#additional-daemons).

For Docker container discovery on the daemon host, see [DOCKER_PROXY_GUIDE.md](DOCKER_PROXY_GUIDE.md).

### Step 4: Configure Discovery

1. Navigate to **Discover > Scheduled**
2. Click **"Create Discovery"**
3. Select the daemon you deployed
4. Choose **Network Scan**
5. Select subnets to scan
6. Set schedule or run manually

### Step 5: Verify

1. Run a manual discovery from **Discover > Sessions**
2. Check **Manage > Hosts** for discovered devices
3. Verify **Topology** shows hosts from all VLANs

For consolidating hosts that appear on multiple VLANs, see [USER_GUIDE.md - Consolidating Hosts](USER_GUIDE.md#consolidating-hosts).

## Network Requirements

### Firewall Rules for Pull Mode (Recommended)

Daemon initiates all connections. Minimal firewall changes needed.

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| Daemon | Server | 60072 | TCP | API communication |
| Daemon | Local subnet | * | TCP | Network scanning |

### Firewall Rules for Push Mode

Server initiates scan requests. Daemon must be reachable.

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| Server | Daemon | 60073 | TCP | Push scan requests |
| Daemon | Server | 60072 | TCP | Report results |
| Daemon | Local subnet | * | TCP | Network scanning |

---

For troubleshooting daemon and discovery issues, see [INSTALLATION.md - Troubleshooting](INSTALLATION.md#troubleshooting).

**Need help?** Join our [Discord](https://discord.gg/b7ffQr8AcZ) or [open an issue](https://github.com/mayanayza/netvisor/issues/new).
