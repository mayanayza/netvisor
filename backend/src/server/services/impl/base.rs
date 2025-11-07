use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::hosts::r#impl::interfaces::Interface;
use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::services::r#impl::bindings::Binding;
use crate::server::services::r#impl::definitions::ServiceDefinitionExt;
use crate::server::services::r#impl::definitions::{DefaultServiceDefinition, ServiceDefinition};
use crate::server::services::r#impl::endpoints::{Endpoint, EndpointResponse};
use crate::server::services::r#impl::patterns::{MatchConfidence, MatchReason, MatchResult};
use crate::server::services::r#impl::virtualization::{
    DockerVirtualization, ServiceVirtualization,
};
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::entities::{DiscoveryMetadata, EntitySource};
use crate::server::subnets::r#impl::base::Subnet;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use std::hash::Hash;
use std::net::IpAddr;
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Validate, Deserialize, PartialEq, Eq, Hash)]
pub struct ServiceBase {
    pub host_id: Uuid,
    pub network_id: Uuid,
    pub service_definition: Box<dyn ServiceDefinition>,
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub bindings: Vec<Binding>,
    pub virtualization: Option<ServiceVirtualization>,
    pub source: EntitySource,
}

impl Default for ServiceBase {
    fn default() -> Self {
        Self {
            host_id: Uuid::nil(),
            network_id: Uuid::nil(),
            service_definition: Box::new(DefaultServiceDefinition),
            name: String::new(),
            bindings: Vec::new(),
            virtualization: None,
            source: EntitySource::Unknown,
        }
    }
}

#[derive(Debug, Clone, Validate, Serialize, Deserialize)]
pub struct Service {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: ServiceBase,
}

#[derive(Debug, Clone)]
pub struct DiscoverySessionServiceMatchParams<'a> {
    pub host_id: &'a Uuid,
    pub gateway_ips: &'a [IpAddr],
    pub daemon_id: &'a Uuid,
    pub network_id: &'a Uuid,
    pub discovery_type: &'a DiscoveryType,
    pub baseline_params: &'a ServiceMatchBaselineParams<'a>,
    pub service_params: ServiceMatchServiceParams<'a>,
}

#[derive(Debug, Clone)]
pub struct ServiceMatchBaselineParams<'a> {
    pub subnet: &'a Subnet,
    pub interface: &'a Interface,
    pub all_ports: &'a Vec<PortBase>,
    pub endpoint_responses: &'a Vec<EndpointResponse>,
    pub virtualization: &'a Option<ServiceVirtualization>,
}

#[derive(Debug, Clone)]
pub struct ServiceMatchServiceParams<'a> {
    pub service_definition: Box<dyn ServiceDefinition>,
    pub matched_services: &'a Vec<Service>,
    pub unbound_ports: &'a Vec<PortBase>,
}

impl PartialEq for Service {
    // Primarily applies to
    fn eq(&self, other: &Self) -> bool {
        let host_match = self.base.host_id == other.base.host_id;
        let network_match = self.base.network_id == other.base.network_id;
        let definition_match =
            self.base.service_definition.id() == other.base.service_definition.id();
        let name_match = self.base.name == other.base.name;
        let id_match = self.id == other.id;

        (host_match && definition_match && name_match && network_match) || id_match
    }
}

impl Default for Service {
    fn default() -> Self {
        Self {
            id: Uuid::nil(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase::default(),
        }
    }
}

impl Hash for Service {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
        self.base.service_definition.hash(state);
        self.base.name.hash(state);
        self.base.host_id.hash(state);
    }
}

impl Display for Service {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}

impl Service {
    pub fn get_binding(&self, id: Uuid) -> Option<&Binding> {
        self.base.bindings.iter().find(|b| b.id() == id)
    }

    pub fn to_bound_interface_ids(&self) -> Vec<Option<Uuid>> {
        self.base
            .bindings
            .iter()
            .map(|i| i.interface_id())
            .collect()
    }

    pub fn to_bound_port_ids(&self) -> Vec<Uuid> {
        self.base
            .bindings
            .iter()
            .filter_map(|i| i.port_id())
            .collect()
    }

    pub fn all_discovery_ports() -> Vec<PortBase> {
        let mut ports: Vec<PortBase> = ServiceDefinitionRegistry::all_service_definitions()
            .iter()
            .flat_map(|s| s.discovery_pattern().ports())
            .collect();

        ports.sort_by_key(|p| (p.number(), p.protocol()));
        ports.dedup();
        ports
    }

    pub fn all_discovery_endpoints() -> Vec<Endpoint> {
        let mut endpoints: Vec<Endpoint> = ServiceDefinitionRegistry::all_service_definitions()
            .iter()
            .flat_map(|s| s.discovery_pattern().endpoints())
            .collect();

        endpoints.sort_by_key(|e| (e.protocol.to_string(), e.port_base.number(), e.path.clone()));
        endpoints.dedup();
        endpoints
    }

    /// Matches scanned data and returns service, vec of matched ports
    pub fn from_discovery(
        params: DiscoverySessionServiceMatchParams,
    ) -> Option<(Self, MatchResult)> {
        let DiscoverySessionServiceMatchParams {
            host_id,
            network_id,
            baseline_params,
            service_params,
            daemon_id,
            discovery_type,
            ..
        } = params.clone();

        let ServiceMatchBaselineParams {
            interface,
            virtualization,
            ..
        } = baseline_params;

        let virtualization = *virtualization;

        let ServiceMatchServiceParams {
            service_definition, ..
        } = service_params;

        if let Ok(mut result) = service_definition.discovery_pattern().matches(&params) {
            tracing::debug!("Matched service with params {:?}", params);

            tracing::info!(
                "{}: Service {:?} matched with ports {:?}",
                interface.base.ip_address,
                service_definition,
                result.ports,
            );

            let mut name = service_definition.name().to_string();

            if ServiceDefinitionExt::is_generic(&service_definition) {
                if let Some(ServiceVirtualization::Docker(DockerVirtualization {
                    container_name: Some(c_name),
                    ..
                })) = virtualization
                {
                    name = c_name.clone()
                }

                // Confidence not applicable for generic services
                result.details.confidence = MatchConfidence::NotApplicable;
                result.details.reason = MatchReason::Container(
                    "Generic service".to_string(),
                    vec![result.details.reason],
                )
            };

            let discovery_metadata = DiscoveryMetadata::new(discovery_type.clone(), *daemon_id);

            let bindings: Vec<Binding> = if !result.ports.is_empty() {
                result
                    .ports
                    .iter()
                    .map(|p| Binding::new_port(p.id, Some(interface.id)))
                    .collect()
            } else {
                vec![Binding::new_interface(interface.id)]
            };

            let service = Service::new(ServiceBase {
                host_id: *host_id,
                network_id: *network_id,
                service_definition,
                name,
                virtualization: virtualization.clone(),
                bindings,
                source: EntitySource::DiscoveryWithMatch {
                    metadata: vec![discovery_metadata],
                    details: result.details.clone(),
                },
            });

            Some((service, result))
        } else {
            None
        }
    }
}
