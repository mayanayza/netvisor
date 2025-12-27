use chrono::{DateTime, Utc};
use mac_address::MacAddress;
use serde::{Deserialize, Serialize};
use std::net::IpAddr;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    hosts::r#impl::{
        base::{Host, HostBase},
        virtualization::HostVirtualization,
    },
    interfaces::r#impl::base::{Interface, InterfaceBase},
    ports::r#impl::base::{Port, PortBase, PortConfig, PortType, TransportProtocol},
    services::r#impl::base::Service,
    shared::types::entities::EntitySource,
};

// =============================================================================
// CONFLICT BEHAVIOR
// =============================================================================

/// How to handle host creation when a matching host already exists
/// (matched via interface MAC address or subnet+IP).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConflictBehavior {
    /// Return an error if a matching host is found.
    /// Used for API users who should edit the existing host instead.
    Error,
    /// Upsert: update the existing host with new data.
    /// Used for daemon discovery which is inherently rediscovering and adding data to the same host
    Upsert,
}

// =============================================================================
// INTERNAL API (daemon discovery)
// =============================================================================

/// Request type for daemon discovery - accepts full entities with IDs.
/// Used internally by daemons for host creation/upsert, NOT the external API.
/// This supports the discovery workflow where daemons manage entity IDs.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct DiscoveryHostRequest {
    pub host: Host,
    pub interfaces: Vec<Interface>,
    pub ports: Vec<Port>,
    pub services: Vec<Service>,
}

// =============================================================================
// EXTERNAL API - CREATE REQUEST TYPES
// =============================================================================

/// Request type for creating a host with its associated interfaces and ports.
/// Server assigns `host_id`, `network_id`, and `source` to all children.
/// Source is automatically set based on how the entity was created (API vs UI).
///
/// Note: Services are created separately via `POST /api/services` after the host exists,
/// as service bindings require the real IDs of the interfaces/ports to reference.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Validate)]
#[schema(example = crate::server::shared::types::examples::create_host_request)]
pub struct CreateHostRequest {
    // Host fields
    #[validate(length(max = 100, message = "Name must be 100 characters or less"))]
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    #[validate(length(max = 500, message = "Description must be 500 characters or less"))]
    pub description: Option<String>,
    // Note: source is auto-set by server (Manual for UI, Api for API calls)
    pub virtualization: Option<HostVirtualization>,
    #[serde(default)]
    pub hidden: bool,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,

    // Children to create with host (server assigns host_id/network_id)
    #[serde(default)]
    pub interfaces: Vec<CreateInterfaceInput>,
    #[serde(default)]
    pub ports: Vec<CreatePortInput>,
    // Note: Services are added separately after host creation via POST /api/services
}

/// Input for creating an interface with a host.
/// `host_id` and `network_id` are assigned by the server.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreateInterfaceInput {
    pub subnet_id: Uuid,
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[schema(value_type = Option<String>)]
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
}

impl CreateInterfaceInput {
    /// Convert to InterfaceBase with the given host_id and network_id.
    /// Uses exhaustive destructuring to ensure compile error if InterfaceBase changes.
    pub fn into_base(self, host_id: Uuid, network_id: Uuid) -> InterfaceBase {
        let CreateInterfaceInput {
            subnet_id,
            ip_address,
            mac_address,
            name,
        } = self;

        // Exhaustive construction ensures we handle all InterfaceBase fields
        InterfaceBase {
            network_id,
            host_id,
            subnet_id,
            ip_address,
            mac_address,
            name,
        }
    }
}

/// Input for creating a port with a host.
/// `host_id` and `network_id` are assigned by the server.
/// The port is specified by number and protocol (e.g., 80/tcp, 443/tcp).
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreatePortInput {
    /// Port number (1-65535)
    pub number: u16,
    /// Transport protocol (Tcp or Udp)
    pub protocol: TransportProtocol,
}

impl CreatePortInput {
    /// Convert to PortBase with the given host_id and network_id.
    pub fn into_base(self, host_id: Uuid, network_id: Uuid) -> PortBase {
        let CreatePortInput { number, protocol } = self;

        PortBase {
            host_id,
            network_id,
            port_type: PortType::Custom(PortConfig { number, protocol }),
        }
    }
}

// =============================================================================
// UPDATE REQUEST TYPE
// =============================================================================

/// Request type for updating a host.
/// Optionally includes interfaces and ports to sync (create/update/delete).
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Validate)]
pub struct UpdateHostRequest {
    pub id: Uuid,
    #[validate(length(max = 100, message = "Name must be 100 characters or less"))]
    pub name: String,
    pub hostname: Option<String>,
    #[validate(length(max = 500, message = "Description must be 500 characters or less"))]
    pub description: Option<String>,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
    // Note: source is not updatable via API
    // Note: network_id is not updatable (would require moving children)
    /// Optional: expected updated_at timestamp for optimistic locking.
    /// If provided, the update will fail with a conflict error if the host
    /// has been modified since this timestamp (e.g., by discovery running
    /// while the user was editing).
    #[serde(default)]
    pub expected_updated_at: Option<DateTime<Utc>>,

    /// Optional: interfaces to sync with this host.
    /// If provided, the server will:
    /// - Create interfaces without an `id` (or with nil UUID)
    /// - Keep/update interfaces with matching `id`
    /// - Delete existing interfaces not in this list
    ///
    /// If not provided (None), interfaces are left unchanged.
    #[serde(default)]
    pub interfaces: Option<Vec<UpdateInterfaceInput>>,

    /// Optional: ports to sync with this host.
    /// If provided, the server will:
    /// - Create ports without an `id` (or with nil UUID)
    /// - Keep/update ports with matching `id`
    /// - Delete existing ports not in this list
    ///
    /// If not provided (None), ports are left unchanged.
    #[serde(default)]
    pub ports: Option<Vec<UpdatePortInput>>,
}

/// Input for syncing an interface during host update.
/// If `id` is None or nil UUID, a new interface is created.
/// If `id` matches an existing interface, it is updated.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct UpdateInterfaceInput {
    /// ID of existing interface to update, or None/nil for new interface
    pub id: Option<Uuid>,
    pub subnet_id: Uuid,
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[schema(value_type = Option<String>)]
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
}

impl UpdateInterfaceInput {
    /// Check if this represents a new interface (no ID or nil UUID)
    pub fn is_new(&self) -> bool {
        self.id.is_none() || self.id == Some(Uuid::nil())
    }

    /// Convert to Interface entity with the given host_id and network_id.
    pub fn into_interface(self, host_id: Uuid, network_id: Uuid) -> Interface {
        let id = if self.is_new() {
            Uuid::new_v4()
        } else {
            self.id.unwrap()
        };

        let now = chrono::Utc::now();
        Interface {
            id,
            created_at: now,
            updated_at: now,
            base: InterfaceBase {
                network_id,
                host_id,
                subnet_id: self.subnet_id,
                ip_address: self.ip_address,
                mac_address: self.mac_address,
                name: self.name,
            },
        }
    }
}

/// Input for syncing a port during host update.
/// If `id` is None or nil UUID, a new port is created.
/// If `id` matches an existing port, it is kept.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct UpdatePortInput {
    /// ID of existing port to keep, or None/nil for new port
    pub id: Option<Uuid>,
    /// Port number (1-65535)
    pub number: u16,
    /// Transport protocol (Tcp or Udp)
    pub protocol: TransportProtocol,
}

impl UpdatePortInput {
    /// Check if this represents a new port (no ID or nil UUID)
    pub fn is_new(&self) -> bool {
        self.id.is_none() || self.id == Some(Uuid::nil())
    }

    /// Convert to Port entity with the given host_id and network_id.
    pub fn into_port(self, host_id: Uuid, network_id: Uuid) -> Port {
        let id = if self.is_new() {
            Uuid::new_v4()
        } else {
            self.id.unwrap()
        };

        let now = chrono::Utc::now();
        Port {
            id,
            created_at: now,
            updated_at: now,
            base: PortBase {
                host_id,
                network_id,
                port_type: PortType::Custom(PortConfig {
                    number: self.number,
                    protocol: self.protocol,
                }),
            },
        }
    }
}

// =============================================================================
// RESPONSE TYPE
// =============================================================================

/// Response type for host endpoints.
/// Includes hydrated children (interfaces, ports, services).
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[schema(example = crate::server::shared::types::examples::host_response)]
pub struct HostResponse {
    // Host identity
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,

    // Host fields
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    pub description: Option<String>,
    pub source: EntitySource,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    pub tags: Vec<Uuid>,

    // Hydrated children (fetched by service layer)
    pub interfaces: Vec<Interface>,
    pub ports: Vec<Port>,
    pub services: Vec<Service>,
}

impl HostResponse {
    /// Convert HostResponse back to a Host entity (without children).
    /// Uses exhaustive destructuring to ensure compile error if HostResponse changes.
    pub fn to_host(&self) -> Host {
        // Exhaustive destructuring of HostResponse
        let HostResponse {
            id,
            created_at,
            updated_at,
            name,
            network_id,
            hostname,
            description,
            source,
            virtualization,
            hidden,
            tags,
            interfaces: _,
            ports: _,
            services: _,
        } = self;

        Host {
            id: *id,
            created_at: *created_at,
            updated_at: *updated_at,
            base: HostBase {
                name: name.clone(),
                network_id: *network_id,
                hostname: hostname.clone(),
                description: description.clone(),
                source: source.clone(),
                virtualization: virtualization.clone(),
                hidden: *hidden,
                tags: tags.clone(),
            },
        }
    }

    /// Build HostResponse from a Host and its hydrated children.
    /// Uses exhaustive destructuring to ensure compile error if Host/HostBase changes.
    pub fn from_host_with_children(
        host: Host,
        interfaces: Vec<Interface>,
        ports: Vec<Port>,
        services: Vec<Service>,
    ) -> Self {
        // Exhaustive destructuring of Host
        let Host {
            id,
            created_at,
            updated_at,
            base,
        } = host;

        // Exhaustive destructuring of HostBase
        // If a field is added to HostBase, this will fail to compile
        let crate::server::hosts::r#impl::base::HostBase {
            name,
            network_id,
            hostname,
            description,
            source,
            virtualization,
            hidden,
            tags,
        } = base;

        Self {
            id,
            created_at,
            updated_at,
            name,
            network_id,
            hostname,
            description,
            source,
            virtualization,
            hidden,
            tags,
            interfaces,
            ports,
            services,
        }
    }
}
