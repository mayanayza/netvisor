use crate::server::hosts::r#impl::ports::PortBase;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::hash::Hash;
use std::{fmt::Display, net::IpAddr};
use strum::IntoDiscriminant;
use strum_macros::{Display, EnumDiscriminants, EnumIter};

#[derive(
    Debug,
    Copy,
    Clone,
    Default,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
    EnumDiscriminants,
    EnumIter,
)]
#[strum_discriminants(derive(Display, Hash, Serialize, Deserialize, EnumIter, PartialOrd, Ord))]
pub enum ApplicationProtocol {
    #[default]
    Http,
    Https,
}

impl Display for ApplicationProtocol {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let str = match self {
            ApplicationProtocol::Http => "http",
            ApplicationProtocol::Https => "https",
        };

        write!(f, "{}", str)
    }
}

#[derive(Debug, Clone, Eq)]
pub struct Endpoint {
    pub protocol: ApplicationProtocol,
    pub ip: Option<IpAddr>,
    pub port_base: PortBase,
    pub path: String,
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct EndpointResponse {
    pub endpoint: Endpoint,
    pub body: String,
    pub headers: HashMap<String, String>,
    pub status: u16,
}

impl Endpoint {
    pub fn is_resolved(&self) -> bool {
        self.ip.is_some()
    }

    pub fn use_ip(&self, ip: IpAddr) -> Self {
        Self {
            protocol: self.protocol,
            ip: Some(ip),
            port_base: self.port_base,
            path: self.path.clone(),
        }
    }

    pub fn http(ip: Option<IpAddr>, path: &str) -> Self {
        Endpoint {
            protocol: ApplicationProtocol::Http,
            port_base: PortBase::Http,
            ip,
            path: path.to_string(),
        }
    }

    pub fn for_pattern(port_base: PortBase, path: &str) -> Self {
        Endpoint {
            protocol: ApplicationProtocol::Http,
            ip: None,
            port_base,
            path: path.to_owned(),
        }
    }
}

impl Display for Endpoint {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self.ip {
            Some(ip) => {
                write!(
                    f,
                    "{}://{}:{}{}",
                    self.protocol.discriminant().to_string().to_lowercase(),
                    ip,
                    self.port_base.number(),
                    self.path
                )
            }
            None => {
                write!(
                    f,
                    "{}://<unresolved>:{}{}",
                    self.protocol.discriminant().to_string().to_lowercase(),
                    self.port_base.number(),
                    self.path
                )
            }
        }
    }
}

impl PartialEq for Endpoint {
    fn eq(&self, other: &Self) -> bool {
        self.protocol == other.protocol
            && self.port_base.number() == other.port_base.number()
            && self.path == other.path
    }
}

impl Hash for Endpoint {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.protocol.hash(state);
        self.port_base.hash(state);
        self.path.hash(state);
    }
}
