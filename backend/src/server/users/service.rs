use crate::server::{
    networks::{
        r#impl::{Network, NetworkBase},
        service::NetworkService,
    },
    shared::{
        services::traits::CrudService,
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
    users::r#impl::base::User,
};
use anyhow::Result;
use async_trait::async_trait;
use std::sync::Arc;

pub struct UserService {
    user_storage: Arc<GenericPostgresStorage<User>>,
    network_service: Arc<NetworkService>,
}

#[async_trait]
impl CrudService<User> for UserService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<User>> {
        &self.user_storage
    }
}

impl UserService {
    pub fn new(
        user_storage: Arc<GenericPostgresStorage<User>>,
        network_service: Arc<NetworkService>,
    ) -> Self {
        Self {
            user_storage,
            network_service,
        }
    }

    /// Create a new user
    pub async fn create_user(&self, user: User) -> Result<(User, Network)> {
        let created_user = self.user_storage.create(&User::new(user.base)).await?;

        let mut network = Network::new(NetworkBase::new(created_user.id));
        network.base.is_default = true;

        let created_network = self.network_service.create(network).await?;

        self.network_service
            .seed_default_data(created_network.id)
            .await?;

        Ok((created_user, created_network))
    }
}
