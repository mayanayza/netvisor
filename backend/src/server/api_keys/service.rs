use anyhow::{Result, anyhow};
use async_trait::async_trait;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    api_keys::r#impl::base::{ApiKey, ApiKeyBase},
    shared::{
        services::traits::CrudService,
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};

pub struct ApiKeyService {
    storage: Arc<GenericPostgresStorage<ApiKey>>,
}

#[async_trait]
impl CrudService<ApiKey> for ApiKeyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<ApiKey>> {
        &self.storage
    }
}

impl ApiKeyService {
    pub fn new(storage: Arc<GenericPostgresStorage<ApiKey>>) -> Self {
        Self { storage }
    }

    pub fn generate_api_key(&self) -> String {
        Uuid::new_v4().simple().to_string()
    }

    pub async fn create(&self, api_key: ApiKey) -> Result<ApiKey> {
        let key = self.generate_api_key();

        let api_key = ApiKey::new(ApiKeyBase {
            key: key.clone(),
            name: api_key.base.name,
            last_used: None,
            expires_at: api_key.base.expires_at,
            network_id: api_key.base.network_id,
            is_enabled: true,
        });

        self.storage.create(&api_key).await
    }

    pub async fn rotate_key(&self, api_key_id: Uuid) -> Result<String> {
        if let Some(mut api_key) = self.get_by_id(&api_key_id).await? {
            let new_key = self.generate_api_key();

            api_key.base.key = new_key.clone();

            self.update(&mut api_key).await?;

            Ok(new_key)
        } else {
            Err(anyhow!(
                "Could not find api key {}. Unable to update API key.",
                api_key_id
            ))
        }
    }
}
