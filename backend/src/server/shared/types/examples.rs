//! Example data for OpenAPI documentation.
//!
//! These examples are used by `#[schema(example = ...)]` attributes to provide
//! realistic sample data in the API documentation. Based on test fixtures but
//! with static placeholder IDs.

use chrono::{TimeZone, Utc};

use crate::server::{
    groups::r#impl::{
        base::{Group, GroupBase},
        types::GroupType,
    },
    hosts::r#impl::{
        api::{CreateHostRequest, CreateInterfaceInput, CreatePortInput, HostResponse},
        base::{Host, HostBase},
    },
    interfaces::r#impl::base::{Interface, InterfaceBase},
    networks::r#impl::{Network, NetworkBase},
    ports::r#impl::base::{Port, PortBase, PortType, TransportProtocol},
    shared::types::entities::EntitySource,
    subnets::r#impl::{
        base::{Subnet, SubnetBase},
        types::SubnetType,
    },
    topology::types::edges::EdgeStyle,
};
use cidr::{IpCidr, Ipv4Cidr};
use mac_address::MacAddress;
use std::net::{IpAddr, Ipv4Addr};

// =============================================================================
// PLACEHOLDER IDS
// =============================================================================

/// Stable placeholder UUIDs for examples.
/// Using deterministic UUIDs so examples are consistent across regenerations.
pub mod ids {
    use uuid::Uuid;

    pub const ORGANIZATION: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440001);
    pub const NETWORK: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440002);
    pub const HOST: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440003);
    pub const SUBNET: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440004);
    pub const INTERFACE: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440005);
    pub const PORT: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440006);
    pub const SERVICE: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440007);
    pub const GROUP: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440008);
    pub const BINDING: Uuid = Uuid::from_u128(0x550e8400_e29b_41d4_a716_446655440009);
}

/// Example timestamp for created_at/updated_at fields.
fn example_timestamp() -> chrono::DateTime<Utc> {
    Utc.with_ymd_and_hms(2024, 1, 15, 10, 30, 0).unwrap()
}

// =============================================================================
// ENTITY EXAMPLES
// =============================================================================

/// Example Network entity.
pub fn network() -> Network {
    Network {
        id: ids::NETWORK,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: NetworkBase {
            name: "Home Network".to_string(),
            is_default: false,
            organization_id: ids::ORGANIZATION,
            tags: vec![],
        },
    }
}

/// Example Host entity.
pub fn host() -> Host {
    Host {
        id: ids::HOST,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: HostBase {
            name: "web-server-01".to_string(),
            hostname: Some("web-server-01.local".to_string()),
            network_id: ids::NETWORK,
            description: Some("Primary web server".to_string()),
            source: EntitySource::Manual,
            virtualization: None,
            hidden: false,
            tags: vec![],
        },
    }
}

/// Example Subnet entity.
pub fn subnet() -> Subnet {
    Subnet {
        id: ids::SUBNET,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: SubnetBase {
            name: "LAN".to_string(),
            description: Some("Local area network".to_string()),
            network_id: ids::NETWORK,
            cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(192, 168, 1, 0), 24).unwrap()),
            subnet_type: SubnetType::Lan,
            source: EntitySource::Manual,
            tags: vec![],
        },
    }
}

/// Example Interface entity.
pub fn interface() -> Interface {
    Interface {
        id: ids::INTERFACE,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: InterfaceBase {
            network_id: ids::NETWORK,
            host_id: ids::HOST,
            subnet_id: ids::SUBNET,
            ip_address: IpAddr::V4(Ipv4Addr::new(192, 168, 1, 100)),
            mac_address: Some(MacAddress::new([0xDE, 0xAD, 0xBE, 0xEF, 0x12, 0x34])),
            name: Some("eth0".to_string()),
        },
    }
}

/// Example Port entity.
pub fn port() -> Port {
    Port {
        id: ids::PORT,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: PortBase {
            host_id: ids::HOST,
            network_id: ids::NETWORK,
            port_type: PortType::Http,
        },
    }
}

/// Example Group entity.
pub fn group() -> Group {
    Group {
        id: ids::GROUP,
        created_at: example_timestamp(),
        updated_at: example_timestamp(),
        base: GroupBase {
            name: "Web Services".to_string(),
            description: Some("HTTP/HTTPS services group".to_string()),
            network_id: ids::NETWORK,
            color: "#3B82F6".to_string(),
            group_type: GroupType::RequestPath,
            binding_ids: vec![],
            source: EntitySource::Manual,
            edge_style: EdgeStyle::Bezier,
            tags: vec![],
        },
    }
}

// =============================================================================
// REQUEST EXAMPLES
// =============================================================================

/// Example CreateHostRequest.
pub fn create_host_request() -> CreateHostRequest {
    CreateHostRequest {
        name: "web-server-01".to_string(),
        network_id: ids::NETWORK,
        hostname: Some("web-server-01.local".to_string()),
        description: Some("Primary web server".to_string()),
        virtualization: None,
        hidden: false,
        tags: vec![],
        interfaces: vec![CreateInterfaceInput {
            subnet_id: ids::SUBNET,
            ip_address: IpAddr::V4(Ipv4Addr::new(192, 168, 1, 100)),
            mac_address: Some(MacAddress::new([0xDE, 0xAD, 0xBE, 0xEF, 0x12, 0x34])),
            name: Some("eth0".to_string()),
        }],
        ports: vec![CreatePortInput {
            number: 80,
            protocol: TransportProtocol::Tcp,
        }],
        services: vec![],
    }
}

// =============================================================================
// RESPONSE EXAMPLES
// =============================================================================

/// Example HostResponse.
pub fn host_response() -> HostResponse {
    HostResponse::from_host_with_children(host(), vec![interface()], vec![port()], vec![])
}
