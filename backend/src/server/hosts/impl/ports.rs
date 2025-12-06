use regex::Regex;
use serde::{Deserialize, Serialize};
use std::hash::Hash;
use std::{fmt::Display, str::FromStr};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use uuid::Uuid;
use validator::Validate;

use crate::server::shared::entities::EntityDiscriminants;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};

#[derive(
    Copy,
    Debug,
    Clone,
    PartialOrd,
    Ord,
    Default,
    Display,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
)]
pub enum TransportProtocol {
    #[default]
    Udp,
    Tcp,
}

#[derive(Copy, Debug, Validate, Clone, Eq)]
pub struct Port {
    pub id: Uuid,
    pub base: PortBase,
}

impl Hash for Port {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.base.hash(state);
    }
}

impl PartialEq for Port {
    fn eq(&self, other: &Self) -> bool {
        self.base == other.base
    }
}

#[derive(
    Copy,
    Debug,
    Clone,
    Eq,
    EnumDiscriminants,
    EnumIter,
    IntoStaticStr,
    Default,
    Serialize,
    Deserialize,
)]
#[strum_discriminants(derive(Display, Hash, EnumIter))]
pub enum PortBase {
    Ssh,
    Telnet,
    DnsUdp,
    DnsTcp,
    Samba,
    Nfs,
    Ftp,
    Ipp,
    LdpTcp,
    LdpUdp,
    Ldap,
    Ldaps,
    Kerberos,
    Snmp,
    Rdp,
    Ntp,
    Sip,
    SipTls,
    Rtsp,
    Dhcp,
    #[default]
    Http,
    MySql,
    PostgreSQL,
    MongoDB,
    Redis,
    MsSql,
    Docker,
    DockerTls,
    Kubernetes,
    RabbitMqMgmt,
    Cassandra,
    Elasticsearch,
    InfluxDb,
    CouchDb,
    Kafka,
    Http3000,
    Http5000,
    #[serde(alias = "HttpAlt")]
    Http8080,
    Http8081,
    Http8082,
    Http8888,
    Http9000,
    Https,
    #[serde(alias = "HttpsAlt")]
    Https8443,
    Https9443,
    Https10443,
    Mqtt,
    MqttTls,
    AMQP,
    AMQPTls,
    Wireguard,
    OpenVPN,
    Custom(PortConfig),
}

impl Hash for PortBase {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.config().hash(state);
    }
}

impl PartialEq for PortBase {
    fn eq(&self, other: &Self) -> bool {
        self.config() == other.config()
    }
}

impl Display for PortBase {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}/{}",
            self.number(),
            self.protocol().to_string().to_lowercase()
        )
    }
}

impl FromStr for PortBase {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(r"(?i)\b(\d+)\s*[/\-\s:]*\s*(tcp|udp)\b").map_err(|e| e.to_string())?;

        if let Some(caps) = re.captures(s.trim()) {
            let number = caps
                .get(1)
                .ok_or("Missing port number")?
                .as_str()
                .parse::<u16>()
                .map_err(|_| "Invalid port number")?;

            let proto_string = caps
                .get(2)
                .ok_or("Missing protocol")?
                .as_str()
                .to_lowercase();

            let protocol = match proto_string.as_str() {
                "tcp" => TransportProtocol::Tcp,
                "udp" => TransportProtocol::Udp,
                _ => return Err("Unknown protocol".into()),
            };

            Ok(PortBase::Custom(PortConfig { number, protocol }))
        } else {
            Err("Failed to parse port and protocol".into())
        }
    }
}

#[derive(Copy, Debug, Clone, Validate, Default, Eq, Serialize, Deserialize)]
pub struct PortConfig {
    #[validate(range(min = 1, max = 65535))]
    pub number: u16,
    pub protocol: TransportProtocol,
}

impl PartialEq for PortConfig {
    fn eq(&self, other: &Self) -> bool {
        self.number == other.number && self.protocol == other.protocol
    }
}

impl Hash for PortConfig {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.number.hash(state);
        self.protocol.hash(state);
    }
}

impl Display for Port {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} (ID: {})", self.base, self.id)
    }
}

impl Port {
    pub fn new(base: PortBase) -> Self {
        Self {
            id: Uuid::new_v4(),
            base,
        }
    }
}

impl PortBase {
    pub fn new(number: u16, protocol: TransportProtocol) -> Self {
        PortBase::Custom(PortConfig { number, protocol })
    }

    pub fn is_tcp(&self) -> bool {
        self.protocol() == TransportProtocol::Tcp
    }
    pub fn is_udp(&self) -> bool {
        self.protocol() == TransportProtocol::Udp
    }

    pub fn new_tcp(number: u16) -> Self {
        PortBase::Custom(PortConfig {
            number,
            protocol: TransportProtocol::Tcp,
        })
    }

    pub fn new_udp(number: u16) -> Self {
        PortBase::Custom(PortConfig {
            number,
            protocol: TransportProtocol::Udp,
        })
    }
    pub fn protocol(&self) -> TransportProtocol {
        self.config().protocol
    }

    pub fn number(&self) -> u16 {
        self.config().number
    }

    pub fn is_custom(&self) -> bool {
        matches!(self, PortBase::Custom(_))
    }

    pub fn is_https(&self) -> bool {
        matches!(
            self,
            PortBase::Https | PortBase::Https10443 | PortBase::Https8443 | PortBase::Https9443
        )
    }

    pub fn config(&self) -> PortConfig {
        match &self {
            PortBase::Ssh => PortConfig {
                number: 22,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Telnet => PortConfig {
                number: 23,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::DnsTcp => PortConfig {
                number: 53,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::DnsUdp => PortConfig {
                number: 53,
                protocol: TransportProtocol::Udp,
            },
            PortBase::Samba => PortConfig {
                number: 445,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Sip => PortConfig {
                number: 5060,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::SipTls => PortConfig {
                number: 5061,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Ldap => PortConfig {
                number: 389,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Ldaps => PortConfig {
                number: 636,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Kerberos => PortConfig {
                number: 88,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Nfs => PortConfig {
                number: 2049,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Ftp => PortConfig {
                number: 21,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Ipp => PortConfig {
                number: 631,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::LdpTcp => PortConfig {
                number: 515,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::LdpUdp => PortConfig {
                number: 515,
                protocol: TransportProtocol::Udp,
            },
            PortBase::Snmp => PortConfig {
                number: 161,
                protocol: TransportProtocol::Udp,
            },
            PortBase::Rdp => PortConfig {
                number: 3389,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Ntp => PortConfig {
                number: 123,
                protocol: TransportProtocol::Udp,
            },
            PortBase::Rtsp => PortConfig {
                number: 554,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Dhcp => PortConfig {
                number: 67,
                protocol: TransportProtocol::Udp,
            },
            PortBase::Http => PortConfig {
                number: 80,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http8080 => PortConfig {
                number: 8080,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Https => PortConfig {
                number: 443,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Https8443 => PortConfig {
                number: 8443,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::MySql => PortConfig {
                number: 3306,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::PostgreSQL => PortConfig {
                number: 5432,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::MongoDB => PortConfig {
                number: 27017,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Redis => PortConfig {
                number: 6379,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::MsSql => PortConfig {
                number: 1433,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Docker => PortConfig {
                number: 2375,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::DockerTls => PortConfig {
                number: 2376,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Kubernetes => PortConfig {
                number: 6443,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::RabbitMqMgmt => PortConfig {
                number: 15672,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Kafka => PortConfig {
                number: 9092,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http3000 => PortConfig {
                number: 3000,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http5000 => PortConfig {
                number: 5000,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http8081 => PortConfig {
                number: 8081,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http8082 => PortConfig {
                number: 8082,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http8888 => PortConfig {
                number: 8888,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Http9000 => PortConfig {
                number: 9000,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Https9443 => PortConfig {
                number: 9443,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Https10443 => PortConfig {
                number: 10443,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Cassandra => PortConfig {
                number: 9042,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Elasticsearch => PortConfig {
                number: 9200,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::InfluxDb => PortConfig {
                number: 8086,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::CouchDb => PortConfig {
                number: 5984,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Custom(config) => *config,
            PortBase::Mqtt => PortConfig {
                number: 1883,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::MqttTls => PortConfig {
                number: 8883,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::AMQP => PortConfig {
                number: 5672,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::AMQPTls => PortConfig {
                number: 5671,
                protocol: TransportProtocol::Tcp,
            },
            PortBase::Wireguard => PortConfig {
                number: 51820,
                protocol: TransportProtocol::Udp,
            },
            PortBase::OpenVPN => PortConfig {
                number: 1194,
                protocol: TransportProtocol::Udp,
            },
        }
    }
}

impl HasId for PortBase {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for PortBase {
    fn color(&self) -> &'static str {
        EntityDiscriminants::Port.color()
    }
    fn icon(&self) -> &'static str {
        EntityDiscriminants::Port.icon()
    }
}

impl TypeMetadataProvider for PortBase {
    fn name(&self) -> &'static str {
        match self {
            PortBase::Ssh => "SSH",
            PortBase::Telnet => "Telnet",
            PortBase::DnsUdp => "DNS (UDP)",
            PortBase::DnsTcp => "DNS (TCP)",
            PortBase::Samba => "Samba",
            PortBase::Nfs => "NFS",
            PortBase::Ftp => "FTP",
            PortBase::Ipp => "IPP",
            PortBase::LdpTcp => "LDP (TCP)",
            PortBase::LdpUdp => "LDP (UDP)",
            PortBase::Snmp => "SNMP",
            PortBase::Ldap => "LDAP",
            PortBase::Ldaps => "LDAP TLS",
            PortBase::Kerberos => "Kerberos",
            PortBase::Rdp => "RDP",
            PortBase::Ntp => "NTP",
            PortBase::Sip => "SIP",
            PortBase::SipTls => "SIP TLS",
            PortBase::Rtsp => "RTSP",
            PortBase::Dhcp => "DHCP",
            PortBase::Http => "HTTP",
            PortBase::Http8080 => "HTTP 8080",
            PortBase::Https => "HTTPS",
            PortBase::Https8443 => "HTTPS 8443",
            PortBase::Custom(_) => "Custom",
            PortBase::MySql => "MySql",
            PortBase::PostgreSQL => "PostgreSql",
            PortBase::MongoDB => "MongoDB",
            PortBase::Redis => "Redis",
            PortBase::MsSql => "MicrosoftSql",
            PortBase::Docker => "Docker",
            PortBase::DockerTls => "Docker TLS",
            PortBase::Kubernetes => "Kubernetes",
            PortBase::RabbitMqMgmt => "RabbitMq Management",
            PortBase::Kafka => "Kafka",
            PortBase::Http3000 => "HTTP 3000",
            PortBase::Http5000 => "HTTP 5000",
            PortBase::Http8081 => "HTTP 8081",
            PortBase::Http8082 => "HTTP 8082",
            PortBase::Http8888 => "HTTP 8888",
            PortBase::Http9000 => "HTTP 9000",
            PortBase::Https9443 => "HTTP 9443",
            PortBase::Https10443 => "HTTP 10443",
            PortBase::Cassandra => "Cassandra",
            PortBase::Elasticsearch => "Elastic Search",
            PortBase::InfluxDb => "InfluxDB",
            PortBase::CouchDb => "CouchDB",
            PortBase::Mqtt => "MQTT",
            PortBase::MqttTls => "MQTT TLS",
            PortBase::AMQP => "AMQP",
            PortBase::AMQPTls => "AMQP TLS",
            PortBase::Wireguard => "Wireguard",
            PortBase::OpenVPN => "OpenVPN",
        }
    }
    fn description(&self) -> &'static str {
        match self {
            PortBase::Ssh => "Secure Shell",
            PortBase::Telnet => "Telnet Protocol",
            PortBase::DnsUdp => "Domain Name System (UDP)",
            PortBase::DnsTcp => "Domain Name System (TCP)",
            PortBase::Samba => "Samba File Sharing",
            PortBase::Nfs => "Network File System",
            PortBase::Ftp => "File Transfer Protocol",
            PortBase::Ipp => "Internet Printing Protocol",
            PortBase::Ldap => "Lightweight Directory Access Protocol",
            PortBase::Ldaps => "Lightweight Directory Access Protocol using TLS",
            PortBase::Sip => "Session Initiation Protocol",
            PortBase::SipTls => "Session Initiation Protocol using TLS",
            PortBase::Kerberos => "Kerberos Authentication Protocol",
            PortBase::LdpTcp => "Line Printer Daemon (TCP)",
            PortBase::LdpUdp => "Line Printer Daemon (UDP)",
            PortBase::Snmp => "Simple Network Management Protocol",
            PortBase::Rdp => "Remote Desktop Protocol",
            PortBase::Ntp => "Network Time Protocol",
            PortBase::Rtsp => "Real-Time Streaming Protocol",
            PortBase::Dhcp => "Dynamic Host Configuration Protocol",
            PortBase::Http => "Hypertext Transfer Protocol",
            PortBase::Http8080 => "HTTP 8080",
            PortBase::Https => "Hypertext Transfer Protocol Secure",
            PortBase::Https8443 => "Alternative HTTPS Port",
            PortBase::MySql => "MySQL Database",
            PortBase::PostgreSQL => "PostgreSQL Database",
            PortBase::MongoDB => "MongoDB",
            PortBase::Redis => "Redis Database",
            PortBase::MsSql => "MicrosoftSQL Database",
            PortBase::Docker => "Docker",
            PortBase::DockerTls => "Docker using TLS",
            PortBase::Kubernetes => "Kubernetes",
            PortBase::RabbitMqMgmt => "RabbitMQ Management",
            PortBase::Kafka => "Kafka",
            PortBase::Http3000 => "HTTP 3000",
            PortBase::Http5000 => "HTTP 5000",
            PortBase::Http8081 => "HTTP 8081",
            PortBase::Http8082 => "HTTP 8082",
            PortBase::Http8888 => "HTTP 8888",
            PortBase::Http9000 => "HTTP 9000",
            PortBase::Https9443 => "HTTPS 9443",
            PortBase::Https10443 => "HTTPS 10443",
            PortBase::Custom(_) => "Custom Port Configuration",
            PortBase::Cassandra => "Cassandra",
            PortBase::Elasticsearch => "Elastic Search",
            PortBase::InfluxDb => "Influx Database",
            PortBase::CouchDb => "Couch Database",
            PortBase::Mqtt => "MQTT",
            PortBase::MqttTls => "MQTT using TLS",
            PortBase::AMQP => "Advanced Message Queuing Protocol",
            PortBase::AMQPTls => "Advanced Message Queuing Protocol using TLS",
            PortBase::Wireguard => "Wireguard VPN",
            PortBase::OpenVPN => "OpenVPN",
        }
    }
    fn metadata(&self) -> serde_json::Value {
        let is_management = matches!(
            self,
            PortBase::Ssh
                | PortBase::Telnet
                | PortBase::Rdp
                | PortBase::Snmp
                | PortBase::Http
                | PortBase::Https
                | PortBase::Http8080
                | PortBase::Https8443
        );

        let is_dns = matches!(self, PortBase::DnsUdp | PortBase::DnsTcp);

        let number = self.number();
        let protocol = self.protocol();

        let can_be_added = !matches!(self, PortBase::Custom(_));

        let is_custom = self.is_custom();

        serde_json::json!({
            "is_management": is_management,
            "is_custom": is_custom,
            "is_dns": is_dns,
            "can_be_added": can_be_added,
            "number": number,
            "protocol": protocol
        })
    }
}

impl Serialize for Port {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::ser::SerializeStruct;
        let mut state = serializer.serialize_struct("Port", 4)?;
        state.serialize_field("id", &self.id)?;

        // Flatten the base fields directly into the Port
        let config = self.base.config();
        state.serialize_field("number", &config.number)?;
        state.serialize_field("protocol", &config.protocol)?;
        state.serialize_field("type", &self.base.id())?;
        state.end()
    }
}

impl<'de> Deserialize<'de> for Port {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        use strum::IntoEnumIterator;

        #[derive(Deserialize)]
        struct TempPort {
            id: Uuid,
            number: u16,
            protocol: TransportProtocol,
            #[serde(rename = "type")]
            _port_type: String,
        }

        let temp = TempPort::deserialize(deserializer)?;

        // Try to find a matching predefined port
        let base = PortBase::iter()
            .find(|variant| {
                // Skip Custom variants during iteration
                if matches!(variant, PortBase::Custom(_)) {
                    return false;
                }
                let config = variant.config();
                config.number == temp.number && config.protocol == temp.protocol
            })
            .unwrap_or({
                // If no predefined port matches, create a Custom variant
                PortBase::Custom(PortConfig {
                    number: temp.number,
                    protocol: temp.protocol,
                })
            });

        Ok(Port { id: temp.id, base })
    }
}
