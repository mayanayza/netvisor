use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::services::definitions::docker_daemon::Docker;
use crate::server::services::definitions::proxmox::Proxmox;
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::patterns::Pattern;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId};
use dyn_clone::DynClone;
use dyn_eq::DynEq;
use dyn_hash::DynHash;
use serde::{Deserialize, Serialize};
use std::hash::Hash;

// Main trait used in service definition implementation
pub trait ServiceDefinition: HasId + DynClone + DynHash + DynEq + Send + Sync {
    /// Service name, will also be used as unique identifier. < 25 characters.
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

    /// Path of service on https://dashboardicons.com/. For example, Home Assistant -> https://dashboardicons.com/icons/home-assistant. MUST SUPPORT SVG ICON FORMAT. If SVG is not supported, a fallback icon will be used instead.
    fn dashboard_icons_path(&self) -> &'static str {
        ""
    }

    /// Path of service on https://simpleicons.org/. For example, Home Assistant -> https://simpleicons.org/icons/homeassistant.svg. MUST SUPPORT SVG ICON FORMAT. If SVG is not supported, a fallback icon will be used instead.
    fn simple_icons_path(&self) -> &'static str {
        ""
    }

    /// Path of service on https://www.vectorlogo.zone. For example, Akamai -> https://www.vectorlogo.zone/logos/akamai/akamai-icon.svg. MUST SUPPORT SVG ICON FORMAT. If SVG is not supported, a fallback icon will be used instead.
    fn vector_logo_zone_icons_path(&self) -> &'static str {
        ""
    }

    /// Path of logo stored in ui/static/logos directory
    fn static_file_path(&self) -> &'static str {
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

    fn dashboard_icons_path(&self) -> &'static str {
        ServiceDefinition::dashboard_icons_path(&**self)
    }

    fn simple_icons_path(&self) -> &'static str {
        ServiceDefinition::simple_icons_path(&**self)
    }

    fn vector_logo_zone_icons_path(&self) -> &'static str {
        ServiceDefinition::vector_logo_zone_icons_path(&**self)
    }

    fn static_file_path(&self) -> &'static str {
        ServiceDefinition::static_file_path(&**self)
    }

    fn logo_needs_white_background(&self) -> bool {
        ServiceDefinition::logo_needs_white_background(&**self)
    }

    fn category(&self) -> ServiceCategory {
        ServiceDefinition::category(&**self)
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        ServiceDefinition::discovery_pattern(&**self)
    }
}

// Helper methods to be used in rest of codebase, not overridable by definition implementations
pub trait ServiceDefinitionExt {
    fn can_be_manually_added(&self) -> bool;
    fn manages_virtualization(&self) -> Option<&'static str>;
    fn is_netvisor(&self) -> bool;
    fn is_generic(&self) -> bool;
    fn is_gateway(&self) -> bool;
    fn has_logo(&self) -> bool;
}

impl ServiceDefinitionExt for Box<dyn ServiceDefinition> {
    fn can_be_manually_added(&self) -> bool {
        !matches!(ServiceDefinition::category(self), ServiceCategory::Netvisor)
    }

    fn is_generic(&self) -> bool {
        ServiceDefinition::is_generic(&**self)
    }

    fn is_netvisor(&self) -> bool {
        matches!(ServiceDefinition::category(self), ServiceCategory::Netvisor)
    }

    fn is_gateway(&self) -> bool {
        self.discovery_pattern().contains_gateway_ip_pattern()
    }

    fn has_logo(&self) -> bool {
        !self.vector_logo_zone_icons_path().is_empty()
            || !self.dashboard_icons_path().is_empty()
            || !self.simple_icons_path().is_empty()
            || !self.static_file_path().is_empty()
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
        let dashboard_icon = ServiceDefinition::dashboard_icons_path(self);
        let simple_icon = ServiceDefinition::simple_icons_path(self);
        let vector_zone_icon = ServiceDefinition::vector_logo_zone_icons_path(self);
        let static_file_icon = ServiceDefinition::static_file_path(self);
        if !dashboard_icon.is_empty() {
            return dashboard_icon;
        } else if !simple_icon.is_empty() {
            return simple_icon;
        } else if !vector_zone_icon.is_empty() {
            return vector_zone_icon;
        } else if !static_file_icon.is_empty() {
            return static_file_icon;
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
        let can_be_added = self.can_be_manually_added();
        let manages_virtualization = self.manages_virtualization();
        let is_gateway = self.is_gateway();
        let logo_source = match self.icon() {
            _ if self.icon() == ServiceDefinition::dashboard_icons_path(self) => {
                Some("dashboard_icons")
            }
            _ if self.icon() == ServiceDefinition::simple_icons_path(self) => Some("simple_icons"),
            _ if self.icon() == ServiceDefinition::vector_logo_zone_icons_path(self) => {
                Some("vector_zone_icons")
            }
            _ if self.icon() == ServiceDefinition::static_file_path(self) => {
                Some("static_file_icon")
            }
            _ => None,
        };
        let logo_needs_white_background = self.logo_needs_white_background();
        serde_json::json!({
            "can_be_added": can_be_added,
            "manages_virtualization": manages_virtualization,
            "is_gateway": is_gateway,
            "logo_source": logo_source,
            "logo_needs_white_background": logo_needs_white_background,
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
        ServiceDefinitionRegistry::find_by_id(&id).ok_or_else(|| {
            serde::de::Error::custom(format!("Service definition not found: {}", id))
        })
    }
}

#[derive(Default, PartialEq, Eq, Hash, Clone)]
pub struct DefaultServiceDefinition;

impl ServiceDefinition for DefaultServiceDefinition {
    fn name(&self) -> &'static str {
        "Default Service"
    }
    fn description(&self) -> &'static str {
        "Default service implementation"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Unknown
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None
    }
}

#[cfg(test)]
mod tests {

    use serial_test::serial;

    use crate::server::services::{
        definitions::ServiceDefinitionRegistry, types::definitions::ServiceDefinition,
    };
    use std::collections::HashSet;

    #[test]
    #[serial]
    fn test_all_service_definitions_register() {
        // Get all registered services using inventory
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        // Verify at least some services are registered
        assert!(
            !registry.is_empty(),
            "No service definitions registered! Check inventory setup."
        );

        // Verify no duplicate names
        let names: HashSet<_> = registry.iter().map(|s| s.name()).collect();
        assert_eq!(
            names.len(),
            registry.len(),
            "Duplicate service definition names found!"
        );

        // Print registered services for debugging
        println!("Registered {} services:", registry.len());
        for service in &registry {
            println!("  - {}", service.name());
        }
    }

    #[test]
    #[serial]
    fn test_service_definition_has_required_fields() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        for service in registry {
            // Every service must have non-empty name
            assert!(!service.name().is_empty(), "Service has empty name");

            // Name should be reasonable length (< 25 chars)
            assert!(
                service.name().len() < 25,
                "Service name '{}' is too long; must be < 25 characters",
                service.name()
            );

            // Every service must have description
            assert!(
                !service.description().is_empty(),
                "Service '{}' has empty description",
                service.name()
            );

            // Description should be reasonable length
            assert!(
                service.description().len() < 100,
                "Service '{}' description is too long; must be < 100 characters",
                service.name()
            );
        }
    }

    #[test]
    #[serial]
    fn test_service_definition_serialization() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        // Test that we can serialize and deserialize service definitions
        for service in registry.iter().take(5) {
            // Test first 5 to save time
            // Serialize to JSON
            let json = serde_json::to_string(&service)
                .expect(&format!("Failed to serialize {}", service.name()));

            // Deserialize back
            let deserialized: Box<dyn ServiceDefinition> = serde_json::from_str(&json)
                .expect(&format!("Failed to deserialize {}", service.name()));

            // Verify key fields match
            assert_eq!(
                service.name(),
                deserialized.name(),
                "Name mismatch after serialization"
            );
            assert_eq!(
                service.description(),
                deserialized.description(),
                "Description mismatch after serialization"
            );
        }
    }
}
