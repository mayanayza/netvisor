use crate::server::{
    networks::{
        service::NetworkService,
        types::{Network, NetworkBase},
    },
    users::{storage::UserStorage, types::base::User},
};
use anyhow::Result;
use std::sync::Arc;
use uuid::Uuid;

pub struct UserService {
    user_storage: Arc<dyn UserStorage>,
    network_service: Arc<NetworkService>,
}

impl UserService {
    pub fn new(user_storage: Arc<dyn UserStorage>, network_service: Arc<NetworkService>) -> Self {
        Self {
            user_storage,
            network_service,
        }
    }

    /// Create a new user
    pub async fn create_user(&self, user: User) -> Result<User> {
        let created_user = self.user_storage.create(&User::new(user.base)).await?;

        tracing::info!(
            "Created user {}: {}",
            created_user.base.name,
            created_user.id
        );

        let mut network = Network::new(NetworkBase::new(created_user.id));
        network.base.is_default = true;

        self.network_service.create_network(network).await?;

        Ok(created_user)
    }

    /// Get user by ID
    pub async fn get_user(&self, id: &Uuid) -> Result<Option<User>> {
        self.user_storage.get_by_id(id).await
    }

    /// Get all users
    pub async fn get_all_users(&self) -> Result<Vec<User>> {
        self.user_storage.get_all().await
    }

    /// Update user
    pub async fn update_user(&self, mut user: User) -> Result<User> {
        let now = chrono::Utc::now();
        user.updated_at = now;

        self.user_storage.update(&user).await?;

        tracing::info!("Updated user {}: {}", user.base.name, user.id);
        Ok(user)
    }

    /// Delete user
    pub async fn delete_user(&self, id: &Uuid) -> Result<()> {
        // Get user to find hosts to update
        let user = self
            .get_user(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        self.user_storage.delete(id).await?;
        tracing::info!("Deleted user {}: {}", user.base.name, user.id);
        Ok(())
    }
}
