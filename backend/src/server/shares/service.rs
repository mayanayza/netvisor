use std::sync::Arc;

use uuid::Uuid;

use crate::server::{
    auth::service::verify_password,
    shared::{
        events::bus::EventBus,
        services::traits::{CrudService, EventBusService},
        storage::generic::GenericPostgresStorage,
    },
    shares::r#impl::base::Share,
};

pub struct ShareService {
    storage: Arc<GenericPostgresStorage<Share>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Share> for ShareService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Share) -> Option<Uuid> {
        Some(entity.base.network_id)
    }

    fn get_organization_id(&self, _entity: &Share) -> Option<Uuid> {
        None
    }
}

impl CrudService<Share> for ShareService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Share>> {
        &self.storage
    }
}

impl ShareService {
    pub fn new(storage: Arc<GenericPostgresStorage<Share>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }

    /// Verify password for a password-protected share
    pub fn verify_share_password(
        &self,
        share: &Share,
        password: &str,
    ) -> Result<(), anyhow::Error> {
        let hash = share
            .base
            .password_hash
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("Share does not require a password"))?;

        verify_password(password, hash)
    }

    /// Validate that a domain is allowed based on the share's allowed_domains setting
    pub fn validate_allowed_domains(&self, share: &Share, referer: Option<&str>) -> bool {
        // If no allowed_domains set, allow all
        let Some(ref allowed) = share.base.allowed_domains else {
            return true;
        };

        // If allowed_domains is empty array, allow all
        if allowed.is_empty() {
            return true;
        }

        // Must have a referer to validate
        let Some(referer) = referer else {
            return false;
        };

        // Parse the referer URL
        let Ok(url) = url::Url::parse(referer) else {
            return false;
        };

        let Some(host) = url.host_str() else {
            return false;
        };

        // Check if host matches any allowed domain (with wildcard support)
        allowed.iter().any(|domain| {
            if domain.starts_with("*.") {
                // Wildcard domain: *.example.com matches foo.example.com
                let suffix = &domain[1..]; // Remove * to get .example.com
                host.ends_with(suffix) || host == &domain[2..] // Also match example.com
            } else {
                host == domain
            }
        })
    }
}
