use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::services::definitions::docker_daemon::Docker;
use crate::server::services::definitions::proxmox::Proxmox;
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::patterns::Pattern;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId};
use dyn_clone::DynClone;
use dyn_eq::DynEq;
use dyn_hash::DynHash;
use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::hash::Hash;
use utoipa::openapi::schema::{ObjectBuilder, SchemaType};
use utoipa::openapi::{RefOr, Schema};
use utoipa::{PartialSchema, ToSchema};

// Main trait used in service definition implementation
pub trait ServiceDefinition: HasId + DynClone + DynHash + DynEq + Send + Sync {
    /// Service name, will also be used as unique identifier. < 40 characters.
    fn name(&self) -> &'static str;

    /// Service description. < 100 characters.
    fn description(&self) -> &'static str;

    /// Category from ServiceCategory enum
    fn category(&self) -> ServiceCategory;

    /// How service should be identified during port scanning
    fn discovery_pattern(&self) -> Pattern<'_>;

    /// If service is not associated with a particular brand or vendor
    fn is_generic(&self) -> bool {
        false
    }

    /// URL of icon, or static path if serving from /logos.
    /// Examples:
    /// Dashboard Icons: Home Assistant -> https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant
    /// Simple Icons: Home Assistant -> https://simpleicons.org/icons/homeassistant.svg.
    /// Vector Logo Icons: Akamai -> https://www.vectorlogo.zone/logos/akamai/akamai-icon.svg
    /// Static file: Scanopy -> /logos/scanopy-logo.png
    fn logo_url(&self) -> &'static str {
        ""
    }

    /// Use this if available logo only has dark variant / if generally it would be more legible with a white background
    fn logo_needs_white_background(&self) -> bool {
        false
    }
}

impl<T: ServiceDefinition> HasId for T
where
    T: ServiceDefinition,
{
    fn id(&self) -> &'static str {
        self.name()
    }
}

impl ServiceDefinition for Box<dyn ServiceDefinition> {
    fn name(&self) -> &'static str {
        ServiceDefinition::name(&**self)
    }

    fn description(&self) -> &'static str {
        ServiceDefinition::description(&**self)
    }

    fn logo_url(&self) -> &'static str {
        ServiceDefinition::logo_url(&**self)
    }

    fn category(&self) -> ServiceCategory {
        ServiceDefinition::category(&**self)
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        ServiceDefinition::discovery_pattern(&**self)
    }

    fn is_generic(&self) -> bool {
        ServiceDefinition::is_generic(&**self)
    }

    fn logo_needs_white_background(&self) -> bool {
        ServiceDefinition::logo_needs_white_background(&**self)
    }
}

// Helper methods to be used in rest of codebase, not overridable by definition implementations
pub trait ServiceDefinitionExt {
    fn can_be_manually_added(&self) -> bool;
    fn manages_virtualization(&self) -> Option<&'static str>;
    fn is_scanopy(&self) -> bool;
    fn is_generic(&self) -> bool;
    fn is_gateway(&self) -> bool;
    fn has_logo(&self) -> bool;
}

impl ServiceDefinitionExt for Box<dyn ServiceDefinition> {
    fn can_be_manually_added(&self) -> bool {
        !matches!(
            ServiceDefinition::category(self),
            ServiceCategory::Scanopy | ServiceCategory::OpenPorts
        )
    }

    fn is_generic(&self) -> bool {
        ServiceDefinition::is_generic(&**self)
    }

    fn is_scanopy(&self) -> bool {
        matches!(ServiceDefinition::category(self), ServiceCategory::Scanopy)
    }

    fn is_gateway(&self) -> bool {
        self.discovery_pattern().contains_gateway_ip_pattern()
    }

    fn has_logo(&self) -> bool {
        !self.logo_url().is_empty()
    }

    fn manages_virtualization(&self) -> Option<&'static str> {
        let id = self.id();
        match id {
            _ if id == Proxmox.id() => Some("vms"),
            _ if id == Docker.id() => Some("containers"),
            _ => None,
        }
    }
}

impl EntityMetadataProvider for Box<dyn ServiceDefinition> {
    fn color(&self) -> &'static str {
        ServiceDefinition::category(self).color()
    }
    fn icon(&self) -> &'static str {
        if !self.logo_url().is_empty() {
            return self.logo_url();
        }
        ServiceDefinition::category(self).icon()
    }
}

impl TypeMetadataProvider for Box<dyn ServiceDefinition> {
    fn name(&self) -> &'static str {
        ServiceDefinition::name(self)
    }
    fn description(&self) -> &'static str {
        ServiceDefinition::description(self)
    }
    fn category(&self) -> &'static str {
        ServiceDefinition::category(self).id()
    }
    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "can_be_added": self.can_be_manually_added(),
            "manages_virtualization": self.manages_virtualization(),
            "is_gateway": self.is_gateway(),
            "has_logo": self.has_logo(),
            "logo_url": self.logo_url(),
            "logo_needs_white_background": self.logo_needs_white_background(),
        })
    }
}

dyn_eq::eq_trait_object!(ServiceDefinition);
dyn_hash::hash_trait_object!(ServiceDefinition);
dyn_clone::clone_trait_object!(ServiceDefinition);

impl Default for Box<dyn ServiceDefinition> {
    fn default() -> Self {
        Box::new(DefaultServiceDefinition)
    }
}

impl std::fmt::Debug for Box<dyn ServiceDefinition> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "name: {}, category: {}, description: {}",
            ServiceDefinition::name(&**self),
            ServiceDefinition::category(&**self),
            ServiceDefinition::description(&**self)
        )
    }
}

impl Serialize for Box<dyn ServiceDefinition> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(self.id())
    }
}

impl<'de> Deserialize<'de> for Box<dyn ServiceDefinition> {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let id = String::deserialize(deserializer)?;
        match ServiceDefinitionRegistry::find_by_id(&id) {
            Some(def) => Ok(def),
            None => {
                // Log a warning but don't fail deserialization
                tracing::warn!(
                    "Service definition not found: '{}'. Using UnknownServiceDefinition as fallback. \
                    This may indicate a missing module declaration in mod.rs or a renamed service.",
                    id
                );

                // Return Default instead of failing
                Ok(Box::new(DefaultServiceDefinition))
            }
        }
    }
}

/// OpenAPI schema for Box<dyn ServiceDefinition>
/// Serializes as a string containing the service definition ID
impl PartialSchema for Box<dyn ServiceDefinition> {
    fn schema() -> RefOr<Schema> {
        use utoipa::openapi::schema::Type;

        RefOr::T(Schema::Object(
            ObjectBuilder::new()
                .schema_type(SchemaType::new(Type::String))
                .description(Some("Service definition ID - references metadata from /api/metadata"))
                .build(),
        ))
    }
}

impl ToSchema for Box<dyn ServiceDefinition> {
    fn name() -> Cow<'static, str> {
        Cow::Borrowed("ServiceDefinitionId")
    }
}

#[derive(Default, PartialEq, Eq, Hash, Clone)]
pub struct DefaultServiceDefinition;

impl ServiceDefinition for DefaultServiceDefinition {
    fn name(&self) -> &'static str {
        "Missing Service"
    }
    fn description(&self) -> &'static str {
        "If you are seeing this, a service definition was removed. Please create an issue."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Unknown
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None
    }
}
