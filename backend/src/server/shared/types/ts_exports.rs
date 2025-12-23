//! TypeScript type exports for frontend consumption.
//!
//! This module contains types that match the JSON API responses exactly.
//! For types with custom serialization (Port, Binding), we define separate
//! TypeScript-friendly structs that match the actual JSON output.
//!
//! To regenerate TypeScript types, run: `cargo test export_typescript_types`

use chrono::{DateTime, Utc};
use mac_address::MacAddress;
use serde::{Deserialize, Serialize};
use std::net::IpAddr;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;

// =============================================================================
// CUSTOM TYPE OVERRIDES FOR TS-RS
// =============================================================================

// IpAddr serializes as a string in JSON
// MacAddress serializes as a string in JSON (e.g., "00:11:22:33:44:55")

// =============================================================================
// SHARED TYPES
// =============================================================================

/// Transport protocol for ports
#[derive(Debug, Clone, Copy, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum TransportProtocol {
    Udp,
    Tcp,
}

// =============================================================================
// ENTITY SOURCE
// =============================================================================

/// How an entity was created/discovered
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[serde(tag = "type")]
pub enum EntitySource {
    #[schema(title = "Manual")]
    Manual,
    #[schema(title = "System")]
    System,
    #[schema(title = "Discovery")]
    Discovery { metadata: Vec<DiscoveryMetadata> },
    #[schema(title = "DiscoveryWithMatch")]
    DiscoveryWithMatch { metadata: Vec<DiscoveryMetadata>, details: MatchDetails },
    #[schema(title = "Unknown")]
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct DiscoveryMetadata {
    #[serde(flatten)]
    pub discovery_type: DiscoveryType,
    pub daemon_id: Uuid,
    pub date: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[serde(tag = "type")]
pub enum DiscoveryType {
    #[schema(title = "SelfReport")]
    SelfReport { host_id: Uuid },
    #[schema(title = "Network")]
    Network {
        subnet_ids: Option<Vec<Uuid>>,
        #[serde(default)]
        host_naming_fallback: Option<HostNamingFallback>,
    },
    #[schema(title = "Docker")]
    Docker {
        host_id: Uuid,
        #[serde(default)]
        host_naming_fallback: Option<HostNamingFallback>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum HostNamingFallback {
    BestService,
    MacVendor,
    IpAddress,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct MatchDetails {
    pub pattern_name: String,
    pub confidence: MatchConfidence,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum MatchConfidence {
    High,
    Medium,
    Low,
}

// =============================================================================
// INTERFACE
// =============================================================================

/// Network interface attached to a host
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Interface {
    pub id: Uuid,
    pub network_id: Uuid,
    pub host_id: Uuid,
    pub subnet_id: Uuid,
    #[ts(type = "string")]
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[ts(type = "string | null")]
    #[schema(value_type = Option<String>)]
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// PORT (matches custom serialization output)
// =============================================================================

/// Port on a host - matches JSON serialization format
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Port {
    pub id: Uuid,
    pub host_id: Uuid,
    pub network_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub number: u16,
    pub protocol: TransportProtocol,
    #[serde(rename = "type")]
    #[ts(rename = "type")]
    pub port_type: String,
}

// =============================================================================
// BINDING (matches custom serialization output)
// =============================================================================

/// Service binding - matches JSON serialization format
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Binding {
    pub id: Uuid,
    pub service_id: Uuid,
    pub network_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(rename = "type")]
    #[ts(rename = "type")]
    pub binding_type: String, // "Interface" or "Port"
    pub interface_id: Option<Uuid>,
    pub port_id: Option<Uuid>,
}

// =============================================================================
// HOST VIRTUALIZATION
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[serde(tag = "type", content = "details")]
pub enum HostVirtualization {
    #[schema(title = "Proxmox")]
    Proxmox(ProxmoxVirtualization),
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct ProxmoxVirtualization {
    pub vm_name: Option<String>,
    pub vm_id: Option<String>,
    pub service_id: Uuid,
}

// =============================================================================
// SERVICE VIRTUALIZATION
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[serde(tag = "type", content = "details")]
pub enum ServiceVirtualization {
    #[schema(title = "Docker")]
    Docker(DockerVirtualization),
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct DockerVirtualization {
    pub container_name: Option<String>,
    pub container_id: Option<String>,
    pub service_id: Uuid,
}

// =============================================================================
// SERVICE
// =============================================================================

/// Service running on a host
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Service {
    pub id: Uuid,
    pub host_id: Uuid,
    pub network_id: Uuid,
    pub name: String,
    /// Service definition ID - metadata fetched from /api/metadata endpoint
    pub service_definition: String,
    pub bindings: Vec<Binding>,
    pub virtualization: Option<ServiceVirtualization>,
    pub source: EntitySource,
    pub tags: Vec<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// HOST RESPONSE
// =============================================================================

/// Host with all its children (interfaces, ports, services)
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct HostResponse {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    pub description: Option<String>,
    pub source: EntitySource,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    pub tags: Vec<Uuid>,
    pub interfaces: Vec<Interface>,
    pub ports: Vec<Port>,
    pub services: Vec<Service>,
}

// =============================================================================
// SUBNET
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Subnet {
    pub id: Uuid,
    pub network_id: Uuid,
    pub name: String,
    pub cidr: String,
    pub description: Option<String>,
    pub subnet_type: SubnetType,
    pub source: EntitySource,
    pub tags: Vec<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum SubnetType {
    Internet,
    Remote,
    Gateway,
    VpnTunnel,
    Dmz,
    Lan,
    WiFi,
    IoT,
    Guest,
    DockerBridge,
    Management,
    Storage,
    Unknown,
    None,
}

// =============================================================================
// NETWORK
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Network {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub name: String,
    pub is_default: bool,
    pub tags: Vec<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// GROUP
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Group {
    pub id: Uuid,
    pub network_id: Uuid,
    pub name: String,
    pub group_type: GroupType,
    pub source: EntitySource,
    pub tags: Vec<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// Group type determines the visual representation and behavior of the group.
/// Binding IDs are stored separately in GroupBase.binding_ids.
#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum GroupType {
    RequestPath,
    HubAndSpoke,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum EdgeStyle {
    Straight,
    SmoothStep,
    Step,
    Bezier,
    SimpleBezier,
}

// =============================================================================
// TAG
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Tag {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub name: String,
    pub color: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// API KEY
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct ApiKey {
    pub id: Uuid,
    pub network_id: Uuid,
    pub name: String,
    pub key: String, // Masked in responses
    pub last_used: Option<DateTime<Utc>>,
    pub expires_at: Option<DateTime<Utc>>,
    pub is_enabled: bool,
    pub tags: Vec<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// DAEMON
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Daemon {
    pub id: Uuid,
    pub network_id: Uuid,
    pub host_id: Option<Uuid>,
    pub url: Option<String>,
    pub mode: DaemonMode,
    pub capabilities: DaemonCapabilities,
    pub version: Option<String>,
    pub last_seen: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum DaemonMode {
    Pull,
    Push,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct DaemonCapabilities {
    pub network_scan: bool,
    pub docker: bool,
    pub proxmox: bool,
    pub self_report: bool,
}

// =============================================================================
// USER
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct User {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub email: String,
    pub name: Option<String>,
    pub permissions: UserPermissions,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum UserPermissions {
    Owner,
    Admin,
    Member,
    Viewer,
}

// =============================================================================
// ORGANIZATION
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Organization {
    pub id: Uuid,
    pub name: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// =============================================================================
// DISCOVERY
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Discovery {
    pub id: Uuid,
    pub network_id: Uuid,
    pub daemon_id: Uuid,
    pub status: DiscoveryStatus,
    pub run_type: DiscoveryRunType,
    pub progress: u8,
    pub message: Option<String>,
    pub started_at: Option<DateTime<Utc>>,
    pub completed_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum DiscoveryStatus {
    Pending,
    Running,
    Completed,
    Failed,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[serde(tag = "type")]
pub enum DiscoveryRunType {
    #[schema(title = "Manual")]
    Manual,
    #[schema(title = "Scheduled")]
    Scheduled { enabled: bool, cron: String },
}

// =============================================================================
// API RESPONSE WRAPPER
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, TS, ToSchema)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

// =============================================================================
// TEST TO GENERATE TYPESCRIPT
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use ts_rs::TS;

    #[test]
    fn export_typescript_types() {
        // This test generates all TypeScript files when run
        // Run with: cargo test export_typescript_types -- --nocapture

        // Explicitly export each type
        TransportProtocol::export_all().unwrap();
        EntitySource::export_all().unwrap();
        DiscoveryMetadata::export_all().unwrap();
        DiscoveryType::export_all().unwrap();
        HostNamingFallback::export_all().unwrap();
        MatchDetails::export_all().unwrap();
        MatchConfidence::export_all().unwrap();
        Interface::export_all().unwrap();
        Port::export_all().unwrap();
        Binding::export_all().unwrap();
        HostVirtualization::export_all().unwrap();
        ProxmoxVirtualization::export_all().unwrap();
        ServiceVirtualization::export_all().unwrap();
        DockerVirtualization::export_all().unwrap();
        Service::export_all().unwrap();
        HostResponse::export_all().unwrap();
        Subnet::export_all().unwrap();
        SubnetType::export_all().unwrap();
        Network::export_all().unwrap();
        Group::export_all().unwrap();
        GroupType::export_all().unwrap();
        EdgeStyle::export_all().unwrap();
        Tag::export_all().unwrap();
        ApiKey::export_all().unwrap();
        Daemon::export_all().unwrap();
        DaemonMode::export_all().unwrap();
        DaemonCapabilities::export_all().unwrap();
        User::export_all().unwrap();
        UserPermissions::export_all().unwrap();
        Organization::export_all().unwrap();
        Discovery::export_all().unwrap();
        DiscoveryStatus::export_all().unwrap();
        DiscoveryRunType::export_all().unwrap();
        ApiResponse::<String>::export_all().unwrap();

        println!("TypeScript types exported to: ../../ui/src/lib/generated/");
    }
}
