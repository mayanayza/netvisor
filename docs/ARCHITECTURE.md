# Architecture Overview

Technical overview of NetVisor's system design, components, and technology stack.

## Table of Contents

- [Components](#components)
- [Technology Stack](#technology-stack)
- [Data Flow](#data-flow)
- [Discovery Pipeline](#discovery-pipeline)
- [Database Schema](#database-schema)
- [Deployment Models](#deployment-models)

## Components

### Server

**Purpose**: Central hub for data storage, API, and web UI serving

**Responsibilities**:
- Store network discovery data in PostgreSQL
- Serve REST API for daemons and UI
- Generate topology visualizations
- Manage user authentication and sessions
- Orchestrate scheduled discoveries
- Handle organization and user management
- Provide real-time updates via Server-Sent Events

**Implementation**:
- Language: Rust
- Framework: Axum (async web framework)
- Database: PostgreSQL 17 with sqlx
- Authentication: tower-sessions + OIDC (openidconnect crate)
- Frontend bundling: Integrated Svelte build in Docker image

**Runs as**: Docker container (recommended) or standalone binary

### Daemon

**Purpose**: Distributed discovery agent that scans networks and reports findings

**Responsibilities**:
- Scan IPv4 addresses on configured subnets
- Detect open TCP ports
- Identify services via pattern matching
- Connect to Docker socket for container discovery
- Report host interfaces and capabilities
- Send heartbeats to maintain connection
- Execute scheduled discovery tasks

**Implementation**:
- Language: Rust
- Network scanning: Custom async TCP scanner with tokio
- Docker API: bollard crate for Docker socket communication
- Service detection: Pattern matching engine with 150+ definitions
- Configuration: JSON file + environment variables + CLI args

**Runs as**: Docker container (Linux only) or standalone binary (all platforms)

### UI

**Purpose**: Web-based interface for viewing and managing network data

**Responsibilities**:
- Display interactive topology diagrams
- Provide CRUD interfaces for all entities
- Monitor discovery sessions in real-time
- Manage users and organizations
- Configure discovery schedules
- Export topology visualizations

**Implementation**:
- Framework: Svelte 5 + SvelteKit
- State management: Svelte stores with derived reactivity
- Visualization: @xyflow/svelte for topology rendering
- Forms: svelte-forms with custom validation
- Styling: Tailwind CSS
- Real-time: Native EventSource for SSE

**Runs as**: Static files served by the server (bundled in Docker image)

## Data Flows

### Discovery Flow (Push)

```
1. User triggers discovery (manual or scheduled)
   │
   ▼
2. Server creates discovery session
   │
   ▼
3. Server sends discovery request to daemon via HTTP
   │
   ▼
4. Daemon executes scan:
   ├─ Network Scan: Scans IP range, detects ports/services
   ├─ Docker Scan: Queries Docker socket for containers
   └─ Self-Report: Reports own capabilities
   │
   ▼
5. Daemon sends discovered entities to server (batched)
   │
   ▼
6. Server processes and stores entities:
   ├─ Creates/updates hosts
   ├─ Creates/updates interfaces
   ├─ Creates/updates services
   ├─ Associates with subnets
   └─ Logs discovery metadata
   │
   ▼
7. Server broadcasts progress updates via SSE
   │
   ▼
8. UI receives real-time updates and refreshes display
   │
   ▼
9. Discovery completes, final status recorded
```

### Discovery Flow (Pull)

```
1. User triggers discovery (manual or scheduled)
   │
   ▼
2. Server creates discovery session
   │
   ▼
3. Daemon polls server for work, and retrieves the discovery session that was just created
   │
   ▼
4 - 9: Same as Discovery Flow (Push)
```

## Discovery Pipeline

### Network Scan Discovery

```
┌──────────────────────────────────────────────────────────┐
│                    Initialization                         │
│  1. Determine target subnets                              │
│  2. Calculate total IP count                              │
│  3. Establish concurrent scan limit                       │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│                 Per-IP Scan (Parallel)                    │
│  1. TCP port scan (common + custom ports)                │
│  2. HTTP endpoint probing                                 │
│  3. Collect responses and headers                         │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│                Service Pattern Matching                   │
│  1. Match port numbers                                    │
│  2. Match HTTP endpoints                                  │
│  3. Check headers and content                             │
│  4. Apply MAC vendor patterns                             │
│  5. Assign confidence score                               │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│                   Host Assembly                           │
│  1. Perform reverse DNS lookup                            │
│  2. Determine hostname (DNS > service > IP)               │
│  3. Group services by interface                           │
│  4. Associate with subnet                                 │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│                 Report to Server                          │
│  1. Send discovered host + interfaces + services          │
│  2. Server stores in database                             │
│  3. Server broadcasts update via SSE                      │
└──────────────────────────────────────────────────────────┘
```

### Docker Discovery

```
┌──────────────────────────────────────────────────────────┐
│               Connect to Docker Socket                    │
│  - Verify socket accessibility                            │
│  - Authenticate (if required)                             │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│              List Running Containers                      │
│  - Get container IDs, names, labels                       │
│  - Extract port mappings                                  │
│  - Identify networks                                      │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│          Inspect Docker Networks                          │
│  - Enumerate bridge networks                              │
│  - Map containers to network subnets                      │
│  - Extract gateway IPs                                    │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│            Match Services to Containers                   │
│  - Use port mappings to identify services                 │
│  - Check container labels for hints                       │
│  - Apply same pattern matching as network scan            │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│         Create Container-Host Relationships               │
│  - Link containers to Docker host                         │
│  - Set virtualization metadata                            │
│  - Create subnet for Docker bridge                        │
└───────────────────┬──────────────────────────────────────┘
                    ▼
┌──────────────────────────────────────────────────────────┐
│                 Report to Server                          │
│  - Send containers as hosts                               │
│  - Send Docker subnets                                    │
│  - Link to host via virtualization field                  │
└──────────────────────────────────────────────────────────┘
```
---

**For implementation details**, see the [source code](https://github.com/netvisor-io/netvisor).