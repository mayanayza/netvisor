use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use crate::server::{
    bindings::r#impl::base::{Binding, BindingBase, BindingType},
    services::r#impl::{
        base::{Service, ServiceBase},
        definitions::ServiceDefinition,
        virtualization::ServiceVirtualization,
    },
    shared::types::entities::EntitySource,
};

// =============================================================================
// CREATE BINDING INPUT
// =============================================================================

/// Input for creating a binding with a service.
/// `service_id` and `network_id` are assigned by the server after the service is created.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(tag = "type")]
pub enum CreateBindingInput {
    /// Bind to an interface (service listens on all ports on this interface)
    #[schema(title = "Interface")]
    Interface { interface_id: Uuid },
    /// Bind to a port (optionally on a specific interface)
    #[schema(title = "Port")]
    Port {
        port_id: Uuid,
        #[serde(skip_serializing_if = "Option::is_none")]
        interface_id: Option<Uuid>,
    },
}

impl CreateBindingInput {
    /// Convert to a full Binding with the given service_id and network_id.
    pub fn into_binding(self, service_id: Uuid, network_id: Uuid) -> Binding {
        let binding_type = match self {
            CreateBindingInput::Interface { interface_id } => {
                BindingType::Interface { interface_id }
            }
            CreateBindingInput::Port {
                port_id,
                interface_id,
            } => BindingType::Port {
                port_id,
                interface_id,
            },
        };

        Binding::new(BindingBase::new(service_id, network_id, binding_type))
    }
}

// =============================================================================
// CREATE SERVICE REQUEST
// =============================================================================

/// Request type for creating a service.
/// Server assigns `id`, `created_at`, `updated_at`, and `source`.
/// Server also assigns `service_id` and `network_id` to all bindings.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreateServiceRequest {
    pub host_id: Uuid,
    pub network_id: Uuid,
    #[schema(value_type = String)]
    // Refer to https://scanopy.net/services for options
    pub service_definition: Box<dyn ServiceDefinition>,
    pub name: String,
    /// Bindings to create with the service.
    /// `service_id` and `network_id` are assigned by the server.
    #[serde(default)]
    pub bindings: Vec<CreateBindingInput>,
    pub virtualization: Option<ServiceVirtualization>,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
}

impl CreateServiceRequest {
    /// Convert to a Service entity with the given source.
    /// Bindings are created with the service's ID and network_id.
    pub fn into_service(self, source: EntitySource) -> Service {
        let CreateServiceRequest {
            host_id,
            network_id,
            service_definition,
            name,
            bindings: binding_inputs,
            virtualization,
            tags,
        } = self;

        // Create the service first to get an ID
        let service_id = Uuid::new_v4();
        let now = chrono::Utc::now();

        // Convert binding inputs to full bindings with the service's ID
        let bindings: Vec<Binding> = binding_inputs
            .into_iter()
            .map(|input| input.into_binding(service_id, network_id))
            .collect();

        Service {
            id: service_id,
            created_at: now,
            updated_at: now,
            base: ServiceBase {
                host_id,
                network_id,
                service_definition,
                name,
                bindings,
                virtualization,
                source,
                tags,
            },
        }
    }

    /// Get network_id for access validation
    pub fn network_id(&self) -> Uuid {
        self.network_id
    }

    /// Get host_id for validation
    pub fn host_id(&self) -> Uuid {
        self.host_id
    }
}
