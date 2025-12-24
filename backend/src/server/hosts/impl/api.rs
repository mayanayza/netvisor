use chrono::{DateTime, Utc};
use mac_address::MacAddress;
use serde::{Deserialize, Serialize};
use std::net::IpAddr;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;

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
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[schema(example = crate::server::shared::types::examples::create_host_request)]
pub struct CreateHostRequest {
    // Host fields
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    pub description: Option<String>,
    // Note: source is auto-set by server (Manual for UI, Api for API calls)
    pub virtualization: Option<HostVirtualization>,
    #[serde(default)]
    pub hidden: bool,
    #[serde(default)]
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
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct CreateInterfaceInput {
    pub subnet_id: Uuid,
    #[ts(type = "string")]
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[ts(type = "string | null")]
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
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
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
/// Children (interfaces, ports, services) are managed via their own endpoints.
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct UpdateHostRequest {
    pub id: Uuid,
    pub name: String,
    pub hostname: Option<String>,
    pub description: Option<String>,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    #[serde(default)]
    pub tags: Vec<Uuid>,
    // Note: source is not updatable via API
    // Note: network_id is not updatable (would require moving children)
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
