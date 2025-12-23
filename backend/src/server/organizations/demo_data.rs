//! Demo data for populating demo organizations with realistic network infrastructure.
//!
//! This module provides a complete dataset representing "Acme Technologies", a mid-size
//! company with MSP operations. The data includes multiple networks, subnets, hosts,
//! services, daemons, API keys, tags, and groups.

use chrono::{DateTime, Utc};
use cidr::{IpCidr, Ipv4Cidr};
use std::net::{IpAddr, Ipv4Addr};
use uuid::Uuid;

use crate::server::{
    api_keys::r#impl::base::{ApiKey, ApiKeyBase},
    bindings::r#impl::base::Binding,
    daemons::r#impl::{
        api::DaemonCapabilities,
        base::{Daemon, DaemonBase, DaemonMode},
    },
    groups::r#impl::{
        base::{Group, GroupBase},
        types::GroupType,
    },
    hosts::r#impl::base::{Host, HostBase},
    interfaces::r#impl::base::{Interface, InterfaceBase},
    networks::r#impl::{Network, NetworkBase},
    ports::r#impl::base::{Port, PortType},
    services::{
        definitions::ServiceDefinitionRegistry,
        r#impl::base::{Service, ServiceBase},
    },
    shared::types::entities::EntitySource,
    subnets::r#impl::{
        base::{Subnet, SubnetBase},
        types::SubnetType,
    },
    tags::r#impl::base::{Tag, TagBase},
    topology::types::{
        base::{Topology, TopologyBase},
        edges::EdgeStyle,
    },
};

// ============================================================================
// Demo Data Container
// ============================================================================

/// A host bundled with its interfaces, ports, and services for creation via discover_host
pub struct HostWithServices {
    pub host: Host,
    pub interfaces: Vec<Interface>,
    pub ports: Vec<Port>,
    pub services: Vec<Service>,
}

/// Container for all demo data entities
pub struct DemoData {
    pub tags: Vec<Tag>,
    pub networks: Vec<Network>,
    pub subnets: Vec<Subnet>,
    pub hosts_with_services: Vec<HostWithServices>,
    pub daemons: Vec<Daemon>,
    pub api_keys: Vec<ApiKey>,
    pub groups: Vec<Group>,
    pub topologies: Vec<Topology>,
}

impl DemoData {
    /// Generate all demo data for the given organization
    /// Note: Groups are intentionally empty - they must be generated after services are created
    /// because group bindings reference actual service binding IDs from the database.
    pub fn generate(organization_id: Uuid) -> Self {
        let now = Utc::now();

        // Generate all entities in dependency order
        let tags = generate_tags(organization_id, now);
        let networks = generate_networks(organization_id, &tags, now);
        let subnets = generate_subnets(&networks, &tags, now);
        let hosts_with_services = generate_hosts_and_services(&networks, &subnets, &tags, now);

        // Collect hosts for daemon generation
        let hosts: Vec<&Host> = hosts_with_services.iter().map(|h| &h.host).collect();

        let daemons = generate_daemons(&networks, &hosts, &subnets, now);
        let api_keys = generate_api_keys(&networks, now);
        let topologies = generate_topologies(&networks, now);

        // Groups are empty - they'll be generated in the handler after services are created
        // This ensures group bindings reference actual service binding IDs
        let groups = vec![];

        Self {
            tags,
            networks,
            subnets,
            hosts_with_services,
            daemons,
            api_keys,
            groups,
            topologies,
        }
    }
}

// ============================================================================
// Topologies
// ============================================================================

fn generate_topologies(networks: &[Network], now: DateTime<Utc>) -> Vec<Topology> {
    networks
        .iter()
        .map(|network| Topology {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: TopologyBase::new(format!("{} Topology", network.base.name), network.id),
        })
        .collect()
}

// ============================================================================
// Tags
// ============================================================================

fn generate_tags(organization_id: Uuid, now: DateTime<Utc>) -> Vec<Tag> {
    let tag_definitions = [
        ("Production", "Systems running in production", "red"),
        ("Development", "Development and test systems", "blue"),
        ("Critical", "Business-critical services", "orange"),
        ("Backup Target", "Backup destinations", "green"),
        ("Monitoring", "Monitoring infrastructure", "purple"),
        ("Database", "Database servers", "cyan"),
        ("Web Tier", "Web and application servers", "teal"),
        ("IoT Device", "Smart devices", "yellow"),
        ("Needs Attention", "Requires admin review", "rose"),
        ("Managed Client", "Client-owned assets", "indigo"),
    ];

    tag_definitions
        .iter()
        .map(|(name, description, color)| Tag {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: TagBase {
                name: name.to_string(),
                description: Some(description.to_string()),
                color: color.to_string(),
                organization_id,
            },
        })
        .collect()
}

// ============================================================================
// Networks
// ============================================================================

fn generate_networks(organization_id: Uuid, tags: &[Tag], now: DateTime<Utc>) -> Vec<Network> {
    let production_tag = tags
        .iter()
        .find(|t| t.base.name == "Production")
        .map(|t| t.id);
    let managed_client_tag = tags
        .iter()
        .find(|t| t.base.name == "Managed Client")
        .map(|t| t.id);

    vec![
        Network {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: NetworkBase {
                name: "Headquarters".to_string(),
                is_default: true,
                organization_id,
                tags: production_tag.into_iter().collect(),
            },
        },
        Network {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: NetworkBase {
                name: "Cloud Infrastructure".to_string(),
                is_default: false,
                organization_id,
                tags: production_tag.into_iter().collect(),
            },
        },
        Network {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: NetworkBase {
                name: "Remote Office - Denver".to_string(),
                is_default: false,
                organization_id,
                tags: vec![],
            },
        },
        Network {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: NetworkBase {
                name: "Client: Riverside Medical".to_string(),
                is_default: false,
                organization_id,
                tags: managed_client_tag.into_iter().collect(),
            },
        },
    ]
}

// ============================================================================
// Subnets
// ============================================================================

fn generate_subnets(networks: &[Network], tags: &[Tag], now: DateTime<Utc>) -> Vec<Subnet> {
    let hq_network = networks
        .iter()
        .find(|n| n.base.name == "Headquarters")
        .unwrap();
    let cloud_network = networks
        .iter()
        .find(|n| n.base.name == "Cloud Infrastructure")
        .unwrap();
    let denver_network = networks
        .iter()
        .find(|n| n.base.name.contains("Denver"))
        .unwrap();
    let riverside_network = networks
        .iter()
        .find(|n| n.base.name.contains("Riverside"))
        .unwrap();

    let monitoring_tag = tags
        .iter()
        .find(|t| t.base.name == "Monitoring")
        .map(|t| t.id);

    vec![
        // Headquarters subnets
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 1, 0), 24).unwrap()),
                network_id: hq_network.id,
                name: "HQ Management".to_string(),
                description: Some("Network management and monitoring".to_string()),
                subnet_type: SubnetType::Management,
                source: EntitySource::Manual,
                tags: monitoring_tag.into_iter().collect(),
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 10, 0), 24).unwrap()),
                network_id: hq_network.id,
                name: "HQ Office LAN".to_string(),
                description: Some("Office workstations".to_string()),
                subnet_type: SubnetType::Lan,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 20, 0), 24).unwrap()),
                network_id: hq_network.id,
                name: "HQ Servers".to_string(),
                description: Some("On-premises servers".to_string()),
                subnet_type: SubnetType::Lan,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 30, 0), 24).unwrap()),
                network_id: hq_network.id,
                name: "HQ IoT".to_string(),
                description: Some("Smart office devices".to_string()),
                subnet_type: SubnetType::IoT,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 100, 0), 24).unwrap()),
                network_id: hq_network.id,
                name: "HQ Guest WiFi".to_string(),
                description: Some("Guest wireless network".to_string()),
                subnet_type: SubnetType::Guest,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(172, 17, 0, 0), 16).unwrap()),
                network_id: hq_network.id,
                name: "HQ Docker Bridge".to_string(),
                description: Some("Docker container network".to_string()),
                subnet_type: SubnetType::DockerBridge,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        // Cloud subnets
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(172, 16, 0, 0), 24).unwrap()),
                network_id: cloud_network.id,
                name: "Cloud Production".to_string(),
                description: Some("Production VPC".to_string()),
                subnet_type: SubnetType::Lan,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(172, 16, 1, 0), 24).unwrap()),
                network_id: cloud_network.id,
                name: "Cloud Database Tier".to_string(),
                description: Some("Database subnet".to_string()),
                subnet_type: SubnetType::Storage,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        // Denver subnets
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(192, 168, 50, 0), 24).unwrap()),
                network_id: denver_network.id,
                name: "Denver Office LAN".to_string(),
                description: Some("Branch office network".to_string()),
                subnet_type: SubnetType::Lan,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 8, 0, 0), 24).unwrap()),
                network_id: denver_network.id,
                name: "Denver VPN Tunnel".to_string(),
                description: Some("Site-to-site VPN to HQ".to_string()),
                subnet_type: SubnetType::VpnTunnel,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        // Riverside Medical subnets
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 100, 0, 0), 24).unwrap()),
                network_id: riverside_network.id,
                name: "Riverside LAN".to_string(),
                description: Some("Client main network".to_string()),
                subnet_type: SubnetType::Lan,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
        Subnet {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: SubnetBase {
                cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 100, 10, 0), 24).unwrap()),
                network_id: riverside_network.id,
                name: "Riverside Management".to_string(),
                description: Some("Client management network".to_string()),
                subnet_type: SubnetType::Management,
                source: EntitySource::Manual,
                tags: vec![],
            },
        },
    ]
}

// ============================================================================
// Hosts and Services
// ============================================================================

/// Helper to create a host with a single interface.
/// Returns (Host, Interface) - host has interface_ids: vec![] initially,
/// the server will populate it after creating the interface.
#[allow(clippy::too_many_arguments)]
fn create_host(
    name: &str,
    hostname: Option<&str>,
    description: Option<&str>,
    network: &Network,
    subnet: &Subnet,
    ip: Ipv4Addr,
    tags: Vec<Uuid>,
    now: DateTime<Utc>,
) -> (Host, Interface) {
    let host_id = Uuid::new_v4();
    let interface = Interface {
        id: Uuid::new_v4(),
        created_at: now,
        updated_at: now,
        base: InterfaceBase {
            network_id: network.id,
            host_id,
            subnet_id: subnet.id,
            ip_address: IpAddr::V4(ip),
            mac_address: None,
            name: Some("eth0".to_string()),
        },
    };
    let host = Host {
        id: host_id,
        created_at: now,
        updated_at: now,
        base: HostBase {
            name: name.to_string(),
            network_id: network.id,
            hostname: hostname.map(String::from),
            description: description.map(String::from),
            source: EntitySource::Manual,
            virtualization: None,
            hidden: false,
            tags,
        },
    };
    (host, interface)
}

/// Helper to create a service for a host.
/// Returns (Service, Option<Port>) - the port must be added to the host's ports list.
fn create_service(
    service_def_id: &str,
    name: &str,
    host: &Host,
    interface: &Interface,
    port_type: Option<PortType>,
    tags: Vec<Uuid>,
    now: DateTime<Utc>,
) -> Option<(Service, Option<Port>)> {
    let service_definition = ServiceDefinitionRegistry::find_by_id(service_def_id)?;

    let (bindings, port) = if let Some(pt) = port_type {
        let port = Port::new_hostless(pt);
        let binding = Binding::new_port_serviceless(port.id, Some(interface.id));
        (vec![binding], Some(port))
    } else {
        let binding = Binding::new_interface_serviceless(interface.id);
        (vec![binding], None)
    };

    Some((
        Service {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: ServiceBase {
                host_id: host.id,
                network_id: host.base.network_id,
                service_definition,
                name: name.to_string(),
                bindings,
                virtualization: None,
                source: EntitySource::Manual,
                tags,
            },
        },
        port,
    ))
}

/// Helper macro to create a host with its services bundled together.
/// Ports are collected separately and bundled with the host.
/// Takes a tuple of (Host, Interface) from create_host().
macro_rules! host_with_services {
    ($host_tuple:expr, $now:expr, $( ($svc_def:expr, $svc_name:expr, $port:expr, $tags:expr) ),* $(,)?) => {{
        let (host, interface) = $host_tuple;
        let interfaces = vec![interface];
        let mut ports = Vec::new();
        let mut services = Vec::new();
        $(
            if let Some((svc, port)) = create_service($svc_def, $svc_name, &host, &interfaces[0], $port, $tags, $now) {
                // Collect port separately if present
                if let Some(p) = port {
                    ports.push(p);
                }
                services.push(svc);
            }
        )*
        HostWithServices { host, interfaces, ports, services }
    }};
}

fn generate_hosts_and_services(
    networks: &[Network],
    subnets: &[Subnet],
    tags: &[Tag],
    now: DateTime<Utc>,
) -> Vec<HostWithServices> {
    let mut result = Vec::new();

    // Helper to find entities
    let find_network = |name: &str| {
        networks
            .iter()
            .find(|n| n.base.name.contains(name))
            .unwrap()
    };
    let find_subnet = |name: &str| subnets.iter().find(|s| s.base.name.contains(name)).unwrap();
    let find_tag = |name: &str| tags.iter().find(|t| t.base.name == name).map(|t| t.id);

    let critical_tag = find_tag("Critical");
    let production_tag = find_tag("Production");
    let database_tag = find_tag("Database");
    let monitoring_tag = find_tag("Monitoring");
    let iot_tag = find_tag("IoT Device");
    let managed_tag = find_tag("Managed Client");
    let web_tier_tag = find_tag("Web Tier");
    let backup_tag = find_tag("Backup Target");

    // ========== HEADQUARTERS NETWORK ==========
    let hq = find_network("Headquarters");
    let hq_mgmt = find_subnet("HQ Management");
    let hq_servers = find_subnet("HQ Servers");
    let hq_lan = find_subnet("HQ Office LAN");
    let hq_iot = find_subnet("HQ IoT");

    // -- pfSense Firewall --
    result.push(host_with_services!(
        create_host(
            "pfsense-fw01",
            Some("pfsense-fw01.acme.local"),
            Some("Primary pfSense firewall"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 1),
            critical_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "pfSense",
            "pfSense",
            Some(PortType::Https),
            critical_tag.into_iter().collect()
        ),
    ));

    // -- UniFi Controller --
    result.push(host_with_services!(
        create_host(
            "unifi-controller",
            Some("unifi.acme.local"),
            Some("UniFi Network Controller"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 10),
            vec![],
            now
        ),
        now,
        (
            "UniFi Controller",
            "UniFi Controller",
            Some(PortType::Https8443),
            vec![]
        ),
    ));

    // -- UniFi Access Point --
    result.push(host_with_services!(
        create_host(
            "unifi-ap-lobby",
            Some("ap-lobby.acme.local"),
            Some("UniFi AP - Main Lobby"),
            hq,
            hq_iot,
            Ipv4Addr::new(10, 0, 30, 100),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Unifi Access Point",
            "UniFi AP",
            None,
            iot_tag.into_iter().collect()
        ),
    ));

    // -- Proxmox Hypervisors --
    result.push(host_with_services!(
        create_host(
            "proxmox-hv01",
            Some("proxmox-hv01.acme.local"),
            Some("Proxmox hypervisor node 1"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 5),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Proxmox VE",
            "Proxmox VE",
            Some(PortType::Https8443),
            production_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "proxmox-hv02",
            Some("proxmox-hv02.acme.local"),
            Some("Proxmox hypervisor node 2"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 6),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Proxmox VE",
            "Proxmox VE",
            Some(PortType::Https8443),
            production_tag.into_iter().collect()
        ),
    ));

    // -- TrueNAS Storage --
    result.push(host_with_services!(
        create_host(
            "truenas-primary",
            Some("truenas.acme.local"),
            Some("Primary NAS storage"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 10),
            critical_tag.into_iter().chain(backup_tag).collect(),
            now
        ),
        now,
        (
            "TrueNAS",
            "TrueNAS",
            Some(PortType::Https),
            backup_tag.into_iter().collect()
        ),
    ));

    // -- Docker Host with Portainer --
    result.push(host_with_services!(
        create_host(
            "docker-prod01",
            Some("docker-prod01.acme.local"),
            Some("Production Docker host"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 20),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Portainer",
            "Portainer",
            Some(PortType::Http9000),
            production_tag.into_iter().collect()
        ),
        ("Docker", "Docker Daemon", Some(PortType::Docker), vec![]),
    ));

    // -- GitLab --
    result.push(host_with_services!(
        create_host(
            "gitlab-server",
            Some("gitlab.acme.local"),
            Some("GitLab instance"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 25),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "GitLab",
            "GitLab",
            Some(PortType::Https),
            production_tag.into_iter().collect()
        ),
    ));

    // -- Jenkins CI --
    result.push(host_with_services!(
        create_host(
            "jenkins-ci",
            Some("jenkins.acme.local"),
            Some("Jenkins CI/CD server"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 30),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Jenkins",
            "Jenkins",
            Some(PortType::Http8080),
            production_tag.into_iter().collect()
        ),
    ));

    // -- Grafana Monitoring --
    result.push(host_with_services!(
        create_host(
            "grafana-mon",
            Some("grafana.acme.local"),
            Some("Grafana monitoring dashboard"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 50),
            monitoring_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Grafana",
            "Grafana",
            Some(PortType::Http3000),
            monitoring_tag.into_iter().collect()
        ),
    ));

    // -- Prometheus --
    result.push(host_with_services!(
        create_host(
            "prometheus",
            Some("prometheus.acme.local"),
            Some("Prometheus metrics server"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 51),
            monitoring_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Prometheus",
            "Prometheus",
            Some(PortType::Http9000),
            monitoring_tag.into_iter().collect()
        ),
    ));

    // -- Uptime Kuma --
    result.push(host_with_services!(
        create_host(
            "uptime-kuma",
            Some("status.acme.local"),
            Some("Uptime Kuma status page"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 52),
            monitoring_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "UptimeKuma",
            "Uptime Kuma",
            Some(PortType::Http3000),
            monitoring_tag.into_iter().collect()
        ),
    ));

    // -- Pi-hole DNS --
    result.push(host_with_services!(
        create_host(
            "pihole-dns",
            Some("pihole.acme.local"),
            Some("Pi-hole DNS ad blocker"),
            hq,
            hq_mgmt,
            Ipv4Addr::new(10, 0, 1, 5),
            vec![],
            now
        ),
        now,
        ("Pi-Hole", "Pi-hole", Some(PortType::Http), vec![]),
    ));

    // -- Vaultwarden --
    result.push(host_with_services!(
        create_host(
            "vaultwarden",
            Some("vault.acme.local"),
            Some("Vaultwarden password manager"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 35),
            critical_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Vaultwarden",
            "Vaultwarden",
            Some(PortType::Https),
            critical_tag.into_iter().collect()
        ),
    ));

    // -- Nextcloud --
    result.push(host_with_services!(
        create_host(
            "nextcloud",
            Some("cloud.acme.local"),
            Some("Nextcloud file sharing"),
            hq,
            hq_servers,
            Ipv4Addr::new(10, 0, 20, 40),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "NextCloud",
            "Nextcloud",
            Some(PortType::Https),
            production_tag.into_iter().collect()
        ),
    ));

    // -- Philips Hue Bridge --
    result.push(host_with_services!(
        create_host(
            "hue-bridge",
            None,
            Some("Philips Hue Bridge"),
            hq,
            hq_iot,
            Ipv4Addr::new(10, 0, 30, 10),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Philips Hue Bridge",
            "Philips Hue",
            Some(PortType::Https),
            iot_tag.into_iter().collect()
        ),
    ));

    // -- HP Printer --
    result.push(host_with_services!(
        create_host(
            "printer-hp-main",
            None,
            Some("HP LaserJet Pro"),
            hq,
            hq_iot,
            Ipv4Addr::new(10, 0, 30, 50),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Hp Printer",
            "HP Printer",
            Some(PortType::Ipp),
            iot_tag.into_iter().collect()
        ),
    ));

    // -- Security Camera --
    result.push(host_with_services!(
        create_host(
            "cam-entrance",
            None,
            Some("Entrance security camera"),
            hq,
            hq_iot,
            Ipv4Addr::new(10, 0, 30, 60),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "RTSP Camera",
            "Security Camera",
            Some(PortType::Rtsp),
            iot_tag.into_iter().collect()
        ),
    ));

    // -- Workstations --
    result.push(host_with_services!(
        create_host(
            "ws-engineering-01",
            Some("ws-eng-01.acme.local"),
            Some("Engineering workstation"),
            hq,
            hq_lan,
            Ipv4Addr::new(10, 0, 10, 101),
            vec![],
            now
        ),
        now,
        ("Workstation", "Workstation", Some(PortType::Rdp), vec![]),
    ));

    result.push(host_with_services!(
        create_host(
            "ws-accounting-01",
            Some("ws-acct-01.acme.local"),
            Some("Accounting workstation"),
            hq,
            hq_lan,
            Ipv4Addr::new(10, 0, 10, 102),
            vec![],
            now
        ),
        now,
        ("Workstation", "Workstation", Some(PortType::Rdp), vec![]),
    ));

    // ========== CLOUD INFRASTRUCTURE ==========
    let cloud = find_network("Cloud");
    let cloud_prod = find_subnet("Cloud Production");
    let cloud_db = find_subnet("Cloud Database");

    // -- Traefik Load Balancer --
    result.push(host_with_services!(
        create_host(
            "traefik-lb01",
            Some("traefik-lb01.cloud.acme.io"),
            Some("Traefik load balancer"),
            cloud,
            cloud_prod,
            Ipv4Addr::new(172, 16, 0, 10),
            production_tag
                .into_iter()
                .chain(critical_tag)
                .chain(web_tier_tag)
                .collect(),
            now
        ),
        now,
        (
            "Traefik",
            "Traefik",
            Some(PortType::Https),
            web_tier_tag.into_iter().collect()
        ),
    ));

    // -- Application Servers --
    result.push(host_with_services!(
        create_host(
            "app-server-01",
            Some("app-01.cloud.acme.io"),
            Some("Application server 1"),
            cloud,
            cloud_prod,
            Ipv4Addr::new(172, 16, 0, 20),
            production_tag.into_iter().chain(web_tier_tag).collect(),
            now
        ),
        now,
        ("SSH", "SSH", Some(PortType::Ssh), vec![]),
        (
            "Web Service",
            "Web Application",
            Some(PortType::Http8080),
            web_tier_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "app-server-02",
            Some("app-02.cloud.acme.io"),
            Some("Application server 2"),
            cloud,
            cloud_prod,
            Ipv4Addr::new(172, 16, 0, 21),
            production_tag.into_iter().chain(web_tier_tag).collect(),
            now
        ),
        now,
        ("SSH", "SSH", Some(PortType::Ssh), vec![]),
        (
            "Web Service",
            "Web Application",
            Some(PortType::Http8080),
            web_tier_tag.into_iter().collect()
        ),
    ));

    // -- PostgreSQL Primary --
    result.push(host_with_services!(
        create_host(
            "postgres-primary",
            Some("pg-primary.cloud.acme.io"),
            Some("PostgreSQL primary"),
            cloud,
            cloud_db,
            Ipv4Addr::new(172, 16, 1, 10),
            database_tag.into_iter().chain(critical_tag).collect(),
            now
        ),
        now,
        (
            "PostgreSQL",
            "PostgreSQL Primary",
            Some(PortType::PostgreSQL),
            database_tag.into_iter().collect()
        ),
    ));

    // -- PostgreSQL Replica --
    result.push(host_with_services!(
        create_host(
            "postgres-replica",
            Some("pg-replica.cloud.acme.io"),
            Some("PostgreSQL replica"),
            cloud,
            cloud_db,
            Ipv4Addr::new(172, 16, 1, 11),
            database_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "PostgreSQL",
            "PostgreSQL Replica",
            Some(PortType::PostgreSQL),
            database_tag.into_iter().collect()
        ),
    ));

    // -- Redis Cache --
    result.push(host_with_services!(
        create_host(
            "redis-cache",
            Some("redis.cloud.acme.io"),
            Some("Redis cache server"),
            cloud,
            cloud_db,
            Ipv4Addr::new(172, 16, 1, 20),
            database_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Redis",
            "Redis",
            Some(PortType::Redis),
            database_tag.into_iter().collect()
        ),
    ));

    // -- Elasticsearch --
    result.push(host_with_services!(
        create_host(
            "elasticsearch",
            Some("es.cloud.acme.io"),
            Some("Elasticsearch cluster"),
            cloud,
            cloud_db,
            Ipv4Addr::new(172, 16, 1, 30),
            database_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Elasticsearch",
            "Elasticsearch",
            Some(PortType::Elasticsearch),
            database_tag.into_iter().collect()
        ),
    ));

    // -- RabbitMQ --
    result.push(host_with_services!(
        create_host(
            "rabbitmq",
            Some("mq.cloud.acme.io"),
            Some("RabbitMQ message broker"),
            cloud,
            cloud_prod,
            Ipv4Addr::new(172, 16, 0, 30),
            production_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "RabbitMQ",
            "RabbitMQ",
            Some(PortType::AMQP),
            production_tag.into_iter().collect()
        ),
    ));

    // ========== DENVER REMOTE OFFICE ==========
    let denver = find_network("Denver");
    let denver_lan = find_subnet("Denver Office LAN");

    result.push(host_with_services!(
        create_host(
            "denver-fw",
            Some("fw.denver.acme.local"),
            Some("Denver branch firewall"),
            denver,
            denver_lan,
            Ipv4Addr::new(192, 168, 50, 1),
            vec![],
            now
        ),
        now,
        ("OPNsense", "OPNsense", Some(PortType::Https), vec![]),
    ));

    result.push(host_with_services!(
        create_host(
            "denver-nas",
            Some("nas.denver.acme.local"),
            Some("Denver local NAS"),
            denver,
            denver_lan,
            Ipv4Addr::new(192, 168, 50, 10),
            backup_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Synology DSM",
            "Synology NAS",
            Some(PortType::Https),
            backup_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "denver-printer",
            None,
            Some("Denver office printer"),
            denver,
            denver_lan,
            Ipv4Addr::new(192, 168, 50, 50),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Hp Printer",
            "HP Printer",
            Some(PortType::Ipp),
            iot_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "denver-ap",
            Some("ap.denver.acme.local"),
            Some("Denver WiFi access point"),
            denver,
            denver_lan,
            Ipv4Addr::new(192, 168, 50, 2),
            iot_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Unifi Access Point",
            "UniFi AP",
            None,
            iot_tag.into_iter().collect()
        ),
    ));

    // ========== RIVERSIDE MEDICAL (CLIENT) ==========
    let riverside = find_network("Riverside");
    let riverside_lan = find_subnet("Riverside LAN");
    let riverside_mgmt = find_subnet("Riverside Management");

    result.push(host_with_services!(
        create_host(
            "rm-firewall",
            Some("fw.riverside-medical.local"),
            Some("Client firewall"),
            riverside,
            riverside_lan,
            Ipv4Addr::new(10, 100, 0, 1),
            managed_tag.into_iter().chain(critical_tag).collect(),
            now
        ),
        now,
        (
            "Fortinet",
            "FortiGate",
            Some(PortType::Https),
            managed_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "rm-dc01",
            Some("dc01.riverside-medical.local"),
            Some("Domain controller"),
            riverside,
            riverside_lan,
            Ipv4Addr::new(10, 100, 0, 10),
            managed_tag.into_iter().chain(critical_tag).collect(),
            now
        ),
        now,
        (
            "Active Directory",
            "Active Directory",
            Some(PortType::Ldap),
            managed_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "rm-fileserver",
            Some("files.riverside-medical.local"),
            Some("File server"),
            riverside,
            riverside_lan,
            Ipv4Addr::new(10, 100, 0, 20),
            managed_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Samba",
            "Samba File Share",
            Some(PortType::Samba),
            managed_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "rm-backup",
            Some("backup.riverside-medical.local"),
            Some("Backup server"),
            riverside,
            riverside_mgmt,
            Ipv4Addr::new(10, 100, 10, 5),
            managed_tag.into_iter().chain(backup_tag).collect(),
            now
        ),
        now,
        (
            "Veeam",
            "Veeam Backup",
            Some(PortType::Https),
            managed_tag.into_iter().chain(backup_tag).collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "rm-reception-01",
            Some("ws-reception.riverside-medical.local"),
            Some("Reception workstation"),
            riverside,
            riverside_lan,
            Ipv4Addr::new(10, 100, 0, 101),
            managed_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Workstation",
            "Workstation",
            Some(PortType::Rdp),
            managed_tag.into_iter().collect()
        ),
    ));

    result.push(host_with_services!(
        create_host(
            "rm-nurse-station-01",
            Some("ws-nurse-01.riverside-medical.local"),
            Some("Nurse station workstation"),
            riverside,
            riverside_lan,
            Ipv4Addr::new(10, 100, 0, 102),
            managed_tag.into_iter().collect(),
            now
        ),
        now,
        (
            "Workstation",
            "Workstation",
            Some(PortType::Rdp),
            managed_tag.into_iter().collect()
        ),
    ));

    result
}

// ============================================================================
// Daemons
// ============================================================================

fn generate_daemons(
    networks: &[Network],
    hosts: &[&Host],
    subnets: &[Subnet],
    now: DateTime<Utc>,
) -> Vec<Daemon> {
    let find_network = |name: &str| {
        networks
            .iter()
            .find(|n| n.base.name.contains(name))
            .unwrap()
    };
    let find_host = |name: &str| hosts.iter().find(|h| h.base.name == name).copied();
    let find_subnet = |name: &str| subnets.iter().find(|s| s.base.name.contains(name));

    let mut daemons = Vec::new();

    // HQ Daemon on docker-prod01
    if let (Some(host), Some(subnet)) = (find_host("docker-prod01"), find_subnet("HQ Servers")) {
        let network = find_network("Headquarters");
        daemons.push(Daemon {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: DaemonBase {
                host_id: host.id,
                network_id: network.id,
                url: "https://docker-prod01.acme.local:8443".to_string(),
                last_seen: now,
                capabilities: DaemonCapabilities {
                    has_docker_socket: true,
                    interfaced_subnet_ids: vec![subnet.id],
                },
                mode: DaemonMode::Push,
                name: "HQ Daemon".to_string(),
                tags: vec![],
            },
        });
    }

    // Cloud Daemon on app-server-01
    if let (Some(host), Some(subnet)) =
        (find_host("app-server-01"), find_subnet("Cloud Production"))
    {
        let network = find_network("Cloud");
        daemons.push(Daemon {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: DaemonBase {
                host_id: host.id,
                network_id: network.id,
                url: "https://app-01.cloud.acme.io:8443".to_string(),
                last_seen: now,
                capabilities: DaemonCapabilities {
                    has_docker_socket: true,
                    interfaced_subnet_ids: vec![subnet.id],
                },
                mode: DaemonMode::Push,
                name: "Cloud Daemon".to_string(),
                tags: vec![],
            },
        });
    }

    // Denver Daemon on denver-nas
    if let (Some(host), Some(subnet)) = (find_host("denver-nas"), find_subnet("Denver Office LAN"))
    {
        let network = find_network("Denver");
        daemons.push(Daemon {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: DaemonBase {
                host_id: host.id,
                network_id: network.id,
                url: "https://nas.denver.acme.local:8443".to_string(),
                last_seen: now,
                capabilities: DaemonCapabilities {
                    has_docker_socket: false,
                    interfaced_subnet_ids: vec![subnet.id],
                },
                mode: DaemonMode::Push,
                name: "Denver Daemon".to_string(),
                tags: vec![],
            },
        });
    }

    // Riverside Daemon on rm-dc01
    if let (Some(host), Some(subnet)) = (find_host("rm-dc01"), find_subnet("Riverside LAN")) {
        let network = find_network("Riverside");
        daemons.push(Daemon {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: DaemonBase {
                host_id: host.id,
                network_id: network.id,
                url: "https://dc01.riverside-medical.local:8443".to_string(),
                last_seen: now,
                capabilities: DaemonCapabilities {
                    has_docker_socket: false,
                    interfaced_subnet_ids: vec![subnet.id],
                },
                mode: DaemonMode::Push,
                name: "Riverside Daemon".to_string(),
                tags: vec![],
            },
        });
    }

    daemons
}

// ============================================================================
// API Keys
// ============================================================================

fn generate_api_keys(networks: &[Network], now: DateTime<Utc>) -> Vec<ApiKey> {
    let find_network = |name: &str| {
        networks
            .iter()
            .find(|n| n.base.name.contains(name))
            .unwrap()
    };

    vec![
        ApiKey {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: ApiKeyBase {
                key: format!("demo_hq_{}", Uuid::new_v4().simple()),
                name: "HQ Daemon Key".to_string(),
                last_used: Some(now),
                expires_at: None,
                network_id: find_network("Headquarters").id,
                is_enabled: true,
                tags: vec![],
            },
        },
        ApiKey {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: ApiKeyBase {
                key: format!("demo_cloud_{}", Uuid::new_v4().simple()),
                name: "Cloud Daemon Key".to_string(),
                last_used: Some(now),
                expires_at: None,
                network_id: find_network("Cloud").id,
                is_enabled: true,
                tags: vec![],
            },
        },
        ApiKey {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: ApiKeyBase {
                key: format!("demo_denver_{}", Uuid::new_v4().simple()),
                name: "Denver Daemon Key".to_string(),
                last_used: Some(now),
                expires_at: None,
                network_id: find_network("Denver").id,
                is_enabled: true,
                tags: vec![],
            },
        },
        ApiKey {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: ApiKeyBase {
                key: format!("demo_riverside_{}", Uuid::new_v4().simple()),
                name: "Riverside Daemon Key".to_string(),
                last_used: Some(now),
                expires_at: None,
                network_id: find_network("Riverside").id,
                is_enabled: true,
                tags: vec![],
            },
        },
    ]
}

// ============================================================================
// Groups
// ============================================================================

/// Generate demo groups using actual created services.
/// This must be called AFTER services are created to ensure binding IDs are correct.
pub fn generate_groups(networks: &[Network], services: &[Service], tags: &[Tag]) -> Vec<Group> {
    let now = Utc::now();
    let cloud = networks
        .iter()
        .find(|n| n.base.name.contains("Cloud"))
        .unwrap();
    let hq = networks
        .iter()
        .find(|n| n.base.name == "Headquarters")
        .unwrap();

    let monitoring_tag = tags
        .iter()
        .find(|t| t.base.name == "Monitoring")
        .map(|t| t.id);

    // Find service bindings for groups
    let find_service_binding = |name: &str| -> Option<Uuid> {
        services
            .iter()
            .find(|s| s.base.name.contains(name))
            .and_then(|s| s.base.bindings.first())
            .map(|b| b.id())
    };

    let mut groups = Vec::new();

    // Web Traffic Flow: Traefik -> App Servers -> PostgreSQL
    let traefik_binding = find_service_binding("Traefik");
    let app_binding = find_service_binding("Web Application");
    let pg_binding = find_service_binding("PostgreSQL Primary");

    if let (Some(traefik), Some(app), Some(pg)) = (traefik_binding, app_binding, pg_binding) {
        groups.push(Group {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: GroupBase {
                name: "Web Traffic Flow".to_string(),
                network_id: cloud.id,
                description: Some("Production web request path from load balancer through app servers to database".to_string()),
                group_type: GroupType::RequestPath,
                binding_ids: vec![traefik, app, pg],
                source: EntitySource::Manual,
                color: "blue".to_string(),
                edge_style: EdgeStyle::Bezier,
                tags: vec![],
            },
        });
    }

    // Monitoring Stack: Prometheus -> Grafana (Hub and Spoke)
    let prometheus_binding = find_service_binding("Prometheus");
    let grafana_binding = find_service_binding("Grafana");
    let uptime_binding = find_service_binding("Uptime Kuma");

    if let (Some(prometheus), Some(grafana)) = (prometheus_binding, grafana_binding) {
        let mut bindings = vec![prometheus, grafana];
        if let Some(uptime) = uptime_binding {
            bindings.push(uptime);
        }
        groups.push(Group {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: GroupBase {
                name: "Monitoring Stack".to_string(),
                network_id: hq.id,
                description: Some(
                    "Prometheus metrics collection with Grafana visualization".to_string(),
                ),
                group_type: GroupType::HubAndSpoke,
                binding_ids: bindings,
                source: EntitySource::Manual,
                color: "purple".to_string(),
                edge_style: EdgeStyle::Straight,
                tags: monitoring_tag.into_iter().collect(),
            },
        });
    }

    // Backup Flow: Servers -> TrueNAS
    let truenas_binding = find_service_binding("TrueNAS");
    let proxmox_binding = find_service_binding("Proxmox");

    if let (Some(proxmox), Some(truenas)) = (proxmox_binding, truenas_binding) {
        groups.push(Group {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base: GroupBase {
                name: "Backup Flow".to_string(),
                network_id: hq.id,
                description: Some("Server backup targets to TrueNAS storage".to_string()),
                group_type: GroupType::RequestPath,
                binding_ids: vec![proxmox, truenas],
                source: EntitySource::Manual,
                color: "green".to_string(),
                edge_style: EdgeStyle::SmoothStep,
                tags: vec![],
            },
        });
    }

    groups
}
