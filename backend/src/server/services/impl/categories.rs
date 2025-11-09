use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::shared::{
    entities::Entity,
    types::metadata::{EntityMetadataProvider, HasId},
};

#[derive(
    Debug,
    Copy,
    Clone,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Display,
    Deserialize,
    EnumDiscriminants,
    EnumIter,
    IntoStaticStr,
)]
pub enum ServiceCategory {
    // Infrastructure (always-on, core network services)
    NetworkCore,     // Routers, switches, core infrastructure
    NetworkAccess,   // WiFi APs, switches for end devices
    NetworkSecurity, // Firewalls, security appliances

    // Server Services
    Storage, // NAS, file servers
    Backup,
    Media,          // Plex, Jellyfin
    HomeAutomation, // Home Assistant
    Virtualization, // Proxmox, ESXi

    // Network Services
    DNS,        // All DNS services
    VPN,        // All VPN services
    Monitoring, // SNMP, monitoring tools
    AdBlock,
    ReverseProxy,

    // End Devices
    Workstation, // Desktops, laptops
    Mobile,      // Phones, tablets
    IoT,         // Smart devices, sensors
    Printer,     // All printing devices

    // Applications
    Web,         // Web servers
    Database,    // DB servers
    Development, // Dev tools, CI/CD
    Dashboard,

    // Special
    Unknown,
    Custom,
    Netvisor,
}

impl HasId for ServiceCategory {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for ServiceCategory {
    fn icon(&self) -> &'static str {
        match self {
            // Infrastructure (always-on, core network services)
            ServiceCategory::NetworkCore => "Network",
            ServiceCategory::NetworkAccess => "Router",
            ServiceCategory::NetworkSecurity => "BrickWallShield",

            // Server Services
            ServiceCategory::Storage => "HardDrive",
            ServiceCategory::Media => "PlayCircle",
            ServiceCategory::HomeAutomation => "Home",
            ServiceCategory::Virtualization => Entity::Virtualization.icon(),

            // Network Services
            ServiceCategory::DNS => Entity::Dns.icon(),
            ServiceCategory::VPN => Entity::Vpn.icon(),
            ServiceCategory::Monitoring => "Activity",
            ServiceCategory::AdBlock => "ShieldCheck",
            ServiceCategory::Backup => "DatabaseBackup",
            ServiceCategory::ReverseProxy => Entity::ReverseProxy.icon(),

            // End devices
            ServiceCategory::Workstation => "Monitor",
            ServiceCategory::Mobile => "Smartphone",
            ServiceCategory::IoT => Entity::IoT.icon(),
            ServiceCategory::Printer => "Printer",

            // Application
            ServiceCategory::Web => "Globe",
            ServiceCategory::Database => "Database",
            ServiceCategory::Development => "Code",
            ServiceCategory::Dashboard => "LayoutDashboard",

            // Unknown
            ServiceCategory::Netvisor => "Zap",
            ServiceCategory::Custom => "Sparkle",
            ServiceCategory::Unknown => "CircleQuestionMark",
        }
    }

    fn color(&self) -> &'static str {
        match self {
            // Infrastructure (always-on, core network services)
            ServiceCategory::NetworkCore => "yellow",
            ServiceCategory::NetworkAccess => "green",
            ServiceCategory::NetworkSecurity => "red",

            // Server Services
            ServiceCategory::Storage => "green",
            ServiceCategory::Media => "blue",
            ServiceCategory::HomeAutomation => "blue",
            ServiceCategory::Virtualization => Entity::Virtualization.color(),
            ServiceCategory::Backup => "gray",

            // Network Services
            ServiceCategory::DNS => Entity::Dns.color(),
            ServiceCategory::VPN => Entity::Vpn.color(),
            ServiceCategory::Monitoring => "orange",
            ServiceCategory::AdBlock => Entity::Dns.color(),
            ServiceCategory::ReverseProxy => Entity::ReverseProxy.color(),

            // End devices
            ServiceCategory::Workstation => "green",
            ServiceCategory::Mobile => "blue",
            ServiceCategory::IoT => Entity::IoT.color(),
            ServiceCategory::Printer => "gray",

            // Application
            ServiceCategory::Web => "blue",
            ServiceCategory::Database => "gray",
            ServiceCategory::Development => "red",
            ServiceCategory::Dashboard => "purple",

            // Unknown
            ServiceCategory::Netvisor => "purple",
            ServiceCategory::Custom => "rose",
            ServiceCategory::Unknown => "gray",
        }
    }
}
