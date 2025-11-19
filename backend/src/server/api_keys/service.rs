use anyhow::{Result, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    api_keys::r#impl::base::{ApiKey, ApiKeyBase},
    auth::middleware::AuthenticatedEntity,
    shared::{
        entities::Entity,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::CrudService,
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};

pub struct ApiKeyService {
    storage: Arc<GenericPostgresStorage<ApiKey>>,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<ApiKey> for ApiKeyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<ApiKey>> {
        &self.storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::ApiKey
    }
    fn get_network_id(&self, entity: &ApiKey) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &ApiKey) -> Option<Uuid> {
        None
    }

    async fn create(&self, api_key: ApiKey, authentication: AuthenticatedEntity) -> Result<ApiKey> {
        let key = self.generate_api_key();

        tracing::debug!(
            api_key_name = %api_key.base.name,
            network_id = %api_key.base.network_id,
            "Creating API key"
        );

        let api_key = ApiKey::new(ApiKeyBase {
            key: key.clone(),
            name: api_key.base.name,
            last_used: None,
            expires_at: api_key.base.expires_at,
            network_id: api_key.base.network_id,
            is_enabled: true,
        });

        let created = self.storage.create(&api_key).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: created.id(),
                network_id: self.get_network_id(&created),
                organization_id: self.get_organization_id(&created),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            api_key_id = %created.id,
            api_key_name = %created.base.name,
            network_id = %created.base.network_id,
            "API key created"
        );

        Ok(created)
    }
}

impl ApiKeyService {
    pub fn new(storage: Arc<GenericPostgresStorage<ApiKey>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }

    pub fn generate_api_key(&self) -> String {
        Uuid::new_v4().simple().to_string()
    }

    pub async fn rotate_key(
        &self,
        api_key_id: Uuid,
        authentication: AuthenticatedEntity,
    ) -> Result<String> {
        tracing::info!(
            api_key_id = %api_key_id,
            "Rotating API key"
        );

        if let Some(mut api_key) = self.get_by_id(&api_key_id).await? {
            let new_key = self.generate_api_key();

            api_key.base.key = new_key.clone();

            let _updated = self.update(&mut api_key, authentication).await?;

            tracing::info!(
                api_key_id = %api_key_id,
                api_key_name = %api_key.base.name,
                "API key rotated successfully"
            );

            Ok(new_key)
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
