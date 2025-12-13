use anyhow::{Result, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use std::net::IpAddr;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    api_keys::r#impl::base::ApiKey,
    auth::middleware::auth::{AuthenticatedEntity, AuthenticatedUser},
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{AuthEvent, AuthOperation, EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};
use sha2::{Digest, Sha256};

pub struct ApiKeyService {
    storage: Arc<GenericPostgresStorage<ApiKey>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<ApiKey> for ApiKeyService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &ApiKey) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &ApiKey) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<ApiKey> for ApiKeyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<ApiKey>> {
        &self.storage
    }

    /// Update entity
    async fn update(
        &self,
        entity: &mut ApiKey,
        authentication: AuthenticatedEntity,
    ) -> Result<ApiKey, anyhow::Error> {
        let current = self
            .get_by_id(&entity.id())
            .await?
            .ok_or_else(|| anyhow!("Could not find {}", entity))?;
        let updated = self.storage().update(entity).await?;

        let suppress_logs = updated.suppress_logs(&current);
        let trigger_stale = updated.triggers_staleness(Some(current));

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: updated.id(),
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                entity_type: updated.clone().into(),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "trigger_stale": trigger_stale,
                    "suppress_logs": suppress_logs
                }),
                authentication,
            })
            .await?;

        Ok(updated)
    }
}

pub fn hash_api_key(key: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(key.as_bytes());
    hex::encode(hasher.finalize())
}

fn generate_api_key() -> String {
    // Return plaintext to user (shown once)
    Uuid::new_v4().simple().to_string()
}

pub fn generate_api_key_for_storage() -> (String, String) {
    let plaintext = generate_api_key();
    let hashed = hash_api_key(&plaintext);
    (plaintext, hashed) // Return both - plaintext for user, hash for DB
}

impl ApiKeyService {
    pub fn new(storage: Arc<GenericPostgresStorage<ApiKey>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }

    pub async fn rotate_key(
        &self,
        api_key_id: Uuid,
        ip_address: IpAddr,
        user_agent: Option<String>,
        user: AuthenticatedUser,
    ) -> Result<String> {
        if let Some(mut api_key) = self.get_by_id(&api_key_id).await? {
            let (plaintext, hashed) = generate_api_key_for_storage();

            api_key.base.key = hashed;

            self.event_bus
                .publish_auth(AuthEvent {
                    id: Uuid::new_v4(),
                    user_id: Some(user.user_id),
                    organization_id: Some(user.organization_id),
                    operation: AuthOperation::RotateKey,
                    timestamp: Utc::now(),
                    ip_address,
                    user_agent,
                    metadata: serde_json::json!({}),
                    authentication: user.clone().into(),
                })
                .await?;

            let _updated = self.update(&mut api_key, user.into()).await?;

            Ok(plaintext)
        } else {
            tracing::warn!(
                api_key_id = %api_key_id,
                "API key not found for rotation"
            );
            Err(anyhow!(
                "Could not find api key {}. Unable to update API key.",
                api_key_id
            ))
        }
    }
}
