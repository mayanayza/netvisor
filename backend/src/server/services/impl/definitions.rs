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

    /// URL of icon, or static path if serving from /logos.
    /// Examples:
    /// Dashboard Icons: Home Assistant -> https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant
    /// Simple Icons: Home Assistant -> https://simpleicons.org/icons/homeassistant.svg.
    /// Vector Logo Icons: Akamai -> https://www.vectorlogo.zone/logos/akamai/akamai-icon.svg
    /// Static file: Netvisor -> /logos/netvisor-logo.png
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
    use strum::{IntoDiscriminant, IntoEnumIterator};

    use crate::server::{
        hosts::r#impl::ports::PortBase,
        services::{
            definitions::ServiceDefinitionRegistry,
            r#impl::{definitions::ServiceDefinition, patterns::Pattern},
        },
    };
    use std::{
        collections::{HashMap, HashSet},
        fs::File,
        io::BufReader,
        path::PathBuf,
    };

    #[test]
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
            println!("  - {}", ServiceDefinition::name(service));
        }
    }

    #[test]
    fn test_service_definition_has_required_fields() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        for service in registry {
            // Every service must have non-empty name
            assert!(
                !ServiceDefinition::name(&service).is_empty(),
                "Service has empty name"
            );

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
    fn test_service_patterns_use_appropriate_port_types() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        // Build map of port numbers to their PortBase names by iterating
        let well_known_ports: std::collections::HashMap<PortBase, String> = PortBase::iter()
            .filter_map(|port_base| {
                // Skip Custom variants
                if matches!(port_base, PortBase::Custom(_)) {
                    None
                } else {
                    Some((port_base, format!("PortBase::{}", port_base.discriminant())))
                }
            })
            .collect();

        for service in registry {
            let pattern = service.discovery_pattern();
            let service_name = ServiceDefinition::name(&service);

            check_port_usage(&pattern, &well_known_ports, service_name);
        }
    }

    fn check_port_usage(
        pattern: &Pattern,
        well_known_ports: &std::collections::HashMap<PortBase, String>,
        service_name: &str,
    ) {
        match pattern {
            Pattern::Port(port_base) | Pattern::Endpoint(port_base, .., None) => {
                if let PortBase::Custom(_) = port_base {
                    if let Some(named_constant) = well_known_ports.get(&port_base) {
                        panic!(
                            "Service '{}' uses custom port {} but should use {} instead",
                            service_name, port_base, named_constant
                        );
                    }
                }
            }
            Pattern::AnyOf(patterns) | Pattern::AllOf(patterns) => {
                for p in patterns {
                    check_port_usage(p, well_known_ports, service_name);
                }
            }
            Pattern::Not(p) => {
                check_port_usage(p, well_known_ports, service_name);
            }
            _ => {}
        }
    }

    #[tokio::test]
    async fn test_service_patterns_are_specific_enough() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();
        let words_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("src")
            .join("tests")
            .join("words.json");

        // Ensure the words file exists, download if necessary
        if !words_path.exists() {
            eprintln!("Words dictionary not found, downloading...");
            let url =
                "https://raw.githubusercontent.com/dwyl/english-words/master/words_dictionary.json";

            // Create the directory if it doesn't exist
            if let Some(parent) = words_path.parent() {
                std::fs::create_dir_all(parent).unwrap();
            }

            // Download and save the file - use async client instead
            let response = reqwest::get(url)
                .await
                .expect("Failed to download words dictionary");
            let content = response.text().await.expect("Failed to read response body");
            std::fs::write(&words_path, content).expect("Failed to write words.json");
            eprintln!("Downloaded words dictionary to {:?}", words_path);
        }

        let words_file = File::open(&words_path).unwrap();
        let reader = BufReader::new(words_file);
        let words_map: HashMap<String, serde_json::Value> =
            serde_json::from_reader(reader).unwrap();
        let words: HashSet<String> = words_map.into_keys().collect();

        // Get all non-custom PortBase variants by iterating
        let common_ports: Vec<PortBase> = PortBase::iter()
            .filter_map(|port_base| {
                // Skip Custom variants
                if matches!(port_base, PortBase::Custom(_)) {
                    None
                } else {
                    Some(port_base)
                }
            })
            .collect();

        for service in registry {
            // Generic services always pass
            if service.is_generic() {
                continue;
            }

            let pattern = service.discovery_pattern();
            let service_name = ServiceDefinition::name(&service);

            check_pattern_specificity(&pattern, &common_ports, service_name, words.clone());
        }
    }

    fn check_pattern_specificity(
        pattern: &Pattern,
        common_ports: &[PortBase],
        service_name: &str,
        words: HashSet<String>,
    ) {
        match pattern {
            // Port-only patterns on common ports without other criteria = fail
            Pattern::Port(port_base) => {
                if common_ports.contains(&port_base) {
                    panic!(
                        "Service '{}' uses port-only pattern on common port {} without additional criteria. \
                        This could cause false positives. Consider using:\n\
                        1. Pattern::Endpoint with a unique path/response\n\
                        2. Pattern::AllOf combining port with other criteria\n\
                        3. Mark service as is_generic = true if it's truly generic (ie it represents the implementation of a protocol, not something provided by a specific vendor)",
                        service_name,
                        port_base.discriminant()
                    );
                }
            }

            // AnyOf with only port patterns on common ports = fail
            Pattern::AnyOf(patterns) => {
                let all_are_common_port_patterns = patterns.iter().all(|p| {
                    if let Pattern::Port(port_base) = p {
                        common_ports.contains(&port_base)
                    } else {
                        false
                    }
                });

                if all_are_common_port_patterns && !patterns.is_empty() {
                    panic!(
                        "Service '{}' uses AnyOf with only common port patterns. \
                        This could cause false positives. Use more specific patterns",
                        service_name
                    );
                }

                // Check each sub-pattern recursively
                for p in patterns {
                    check_pattern_specificity(p, common_ports, service_name, words.clone());
                }
            }

            // Endpoint patterns with common port/path and match strings that could lead to false positive = fail
            Pattern::Endpoint(port_base, path, body_match_string, status_range) => {
                let match_string_lower = body_match_string.to_lowercase();
                let is_short_match_string = match_string_lower.len() < 5;

                // Another service is likely to be listening on this port on other hosts, so need to be more stringent
                let port_is_common = common_ports.contains(&port_base);

                // Path is unique/specific enough, even if match string alone is likely to cause false positives
                let path_contains_service_name = path.contains(service_name);

                // Endpoint is probably not unique to service, and other services might respond to it
                let is_common_endpoint = !path_contains_service_name
                    && port_is_common
                    && (*path == "/" || *path == "/api/" || *path == "/home/");

                // Potential to false positive with dashboards that display service name
                let match_string_is_service_name =
                    match_string_lower == service_name.to_lowercase();

                // Non-compound strings have potential to false positive with dashboards that display service name
                let match_string_is_singular = !match_string_lower.contains(" ")
                    && !match_string_lower.contains(".")
                    && !match_string_lower.contains("_")
                    && !match_string_lower.contains("-")
                    && !match_string_lower.contains(",")
                    && !match_string_lower.contains("/");

                // Potential to false positive by being found in random strings displayed by other services
                let is_substring_of_any_word = if is_short_match_string {
                    words.iter().any(|w| w.contains(&match_string_lower))
                        && !path_contains_service_name
                } else {
                    false
                };

                let expected_range = status_range.as_ref().unwrap_or(&(200..400));
                let range_includes_redirects =
                    expected_range.start < 400 && expected_range.end > 300;

                if is_short_match_string && range_includes_redirects && port_is_common {
                    panic!(
                        "Service '{}' uses a match string '{}' that is too short ({} characters) and also accepts redirects.
                        This could cause false positives. Please disallow redirects by passing Some(200..300) as the allowed status range
                        or update the match string to be longer.",
                        service_name,
                        body_match_string,
                        match_string_lower.len(),
                    );
                };

                if is_common_endpoint && match_string_is_service_name {
                    panic!(
                        "Service '{}' uses a match string '{}' that is the same as the name of the service. This could cause false positives, \
                        as dashboard services often will contain service names in their own endpoint responses, and as such could get detected as this service
                        Please provide a match string that contains text that distinguishes it from the service name",
                        service_name, body_match_string
                    );
                }

                if is_common_endpoint && match_string_is_singular {
                    panic!(
                        "Service '{}' uses a match string '{}' that is a singular word. This could cause false positives, \
                        as dashboard services often will contain service names in their own endpoint responses, and as such could get detected as this service
                        Please provide a compound match string - multiple words separated by one of the following \
                        delimiters: \".\", \"_\", \"/\", \",\", or \"-\"",
                        service_name, body_match_string
                    );
                }

                if is_common_endpoint && is_substring_of_any_word {
                    panic!(
                        "Service '{}' uses endpoint pattern at root path '/' on common port {} \
                        with a match string '{}' that is a substring of at least one of a common english word. This could cause false positives. \
                        Consider:\n\
                        1. Use a more specific path (e.g., '/api/status' instead of '/')\n\
                        2. Use a longer, more unique match string\n\
                        3. Use Pattern::AllOf to combine multiple criteria",
                        service_name, port_base, body_match_string
                    );
                }
            }

            // Other patterns are generally fine
            _ => {}
        }
    }

    #[test]
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
    #[tokio::test]
    async fn test_service_definition_logo_urls_resolve() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();
        let client = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(5))
            .build()
            .expect("Failed to create HTTP client");

        const ALLOWED_DOMAINS: &[&str] =
            &["cdn.jsdelivr.net", "simpleicons.org", "vectorlogo.zone"];

        for service in registry {
            let logo_url = service.logo_url();

            // Skip services without logo URLs
            if logo_url.is_empty() {
                continue;
            }

            // Check if it's a local file path or external URL
            if logo_url.starts_with('/') {
                // Local file path like /logos/netvisor-logo.png
                assert!(
                    logo_url.starts_with("/logos/"),
                    "Service '{}' has local logo URL '{}' that doesn't start with /logos/",
                    ServiceDefinition::name(&service),
                    logo_url
                );
                // We can't verify local files exist in tests, so just validate the path format
                continue;
            }

            // Must be a URL - parse it
            let url = match reqwest::Url::parse(logo_url) {
                Ok(url) => url,
                Err(e) => {
                    panic!(
                        "Service '{}' has invalid logo URL '{}': {}",
                        ServiceDefinition::name(&service),
                        logo_url,
                        e
                    );
                }
            };

            // Check domain is in allowed list
            let domain = url.domain().unwrap_or("");
            let is_allowed = ALLOWED_DOMAINS
                .iter()
                .any(|allowed| domain.ends_with(allowed));

            assert!(
                is_allowed,
                "Service '{}' has logo URL '{}' from unauthorized domain '{}'. \
             Allowed domains: {}",
                ServiceDefinition::name(&service),
                logo_url,
                domain,
                ALLOWED_DOMAINS.join(", ")
            );

            // Attempt to fetch the logo URL
            match client.head(logo_url).send().await {
                Ok(response) => {
                    assert!(
                        response.status().is_success(),
                        "Service '{}' has logo URL '{}' that returned status {}",
                        ServiceDefinition::name(&service),
                        logo_url,
                        response.status()
                    );

                    // Verify Content-Type is an image
                    if let Some(content_type) = response.headers().get("content-type") {
                        let content_type_str = content_type.to_str().unwrap_or("");
                        assert!(
                            content_type_str.starts_with("image/")
                                || content_type_str.starts_with("text/plain"),
                            "Service '{}' has logo URL '{}' with non-image Content-Type: {}",
                            ServiceDefinition::name(&service),
                            logo_url,
                            content_type_str
                        );
                    }
                }
                Err(e) => {
                    panic!(
                        "Service '{}' has logo URL '{}' that failed to resolve: {}",
                        ServiceDefinition::name(&service),
                        logo_url,
                        e
                    );
                }
            }
        }
    }

    #[test]
    fn test_service_definition_description_starts_with_capital() {
        let registry = ServiceDefinitionRegistry::all_service_definitions();

        for service in registry {
            let description = ServiceDefinition::description(&service);

            // Skip empty descriptions (already caught by another test)
            if description.is_empty() {
                continue;
            }

            let first_char = description.chars().next().unwrap();
            assert!(
                first_char.is_uppercase(),
                "Service '{}' has description '{}' that doesn't start with a capital letter",
                ServiceDefinition::name(&service),
                description
            );
        }
    }
}
