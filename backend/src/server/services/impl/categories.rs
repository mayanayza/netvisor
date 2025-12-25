use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;

use crate::server::shared::{
    concepts::Concept,
    entities::EntityDiscriminants,
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
    ToSchema,
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
    Database,    // DB servers
    Development, // Dev tools, CI/CD
    Dashboard,
    MessageQueue,
    IdentityAndAccess,

    // Office & Productivity
    Office,            // Document editing, notes, file management
    ProjectManagement, // Task tracking, wikis, kanban boards

    // Communication
    Messaging,    // Team chat (text-based)
    Conferencing, // Video/audio meetings
    Telephony,    // VoIP/PBX infrastructure
    Email,        // Email servers

    // Content
    Publishing, // CMS, blogs, forums

    // Special
    Unknown,
    Custom,
    Scanopy,
    OpenPorts,
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
            ServiceCategory::Virtualization => Concept::Virtualization.icon(),
            ServiceCategory::Backup => "DatabaseBackup",

            // Network Services
            ServiceCategory::DNS => Concept::Dns.icon(),
            ServiceCategory::VPN => Concept::Vpn.icon(),
            ServiceCategory::Monitoring => "Activity",
            ServiceCategory::AdBlock => "ShieldCheck",
            ServiceCategory::ReverseProxy => Concept::ReverseProxy.icon(),

            // End devices
            ServiceCategory::Workstation => "Monitor",
            ServiceCategory::Mobile => "Smartphone",
            ServiceCategory::IoT => Concept::IoT.icon(),
            ServiceCategory::Printer => "Printer",

            // Applications
            ServiceCategory::Database => "Database",
            ServiceCategory::Development => "Code",
            ServiceCategory::MessageQueue => "MessageSquareCode",
            ServiceCategory::Dashboard => "LayoutDashboard",
            ServiceCategory::IdentityAndAccess => "KeyRound",

            // Office & Productivity
            ServiceCategory::Office => "FileText",
            ServiceCategory::ProjectManagement => "KanbanSquare",

            // Communication
            ServiceCategory::Messaging => "MessageCircle",
            ServiceCategory::Conferencing => "Video",
            ServiceCategory::Telephony => "Phone",
            ServiceCategory::Email => "Mail",

            // Content
            ServiceCategory::Publishing => "PenLine",

            // Special
            ServiceCategory::Scanopy => "Zap",
            ServiceCategory::Custom => "Sparkle",
            ServiceCategory::OpenPorts => EntityDiscriminants::Port.icon(),
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
            ServiceCategory::Virtualization => Concept::Virtualization.color(),
            ServiceCategory::Backup => "gray",

            // Network Services
            ServiceCategory::DNS => Concept::Dns.color(),
            ServiceCategory::VPN => Concept::Vpn.color(),
            ServiceCategory::Monitoring => "orange",
            ServiceCategory::AdBlock => Concept::Dns.color(),
            ServiceCategory::ReverseProxy => Concept::ReverseProxy.color(),

            // End devices
            ServiceCategory::Workstation => "green",
            ServiceCategory::Mobile => "blue",
            ServiceCategory::IoT => Concept::IoT.color(),
            ServiceCategory::Printer => "gray",

            // Applications
            ServiceCategory::Database => "gray",
            ServiceCategory::Development => "red",
            ServiceCategory::Dashboard => "purple",
            ServiceCategory::MessageQueue => "green",
            ServiceCategory::IdentityAndAccess => "yellow",

            // Office & Productivity
            ServiceCategory::Office => "blue",
            ServiceCategory::ProjectManagement => "indigo",

            // Communication
            ServiceCategory::Messaging => "green",
            ServiceCategory::Conferencing => "teal",
            ServiceCategory::Telephony => "orange",
            ServiceCategory::Email => "rose",

            // Content
            ServiceCategory::Publishing => "violet",

            // Special
            ServiceCategory::Scanopy => "purple",
            ServiceCategory::Custom => "rose",
            ServiceCategory::OpenPorts => EntityDiscriminants::Port.color(),
            ServiceCategory::Unknown => "gray",
        }
    }
}
