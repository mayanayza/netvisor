use crate::server::{
    auth::middleware::AuthenticatedEntity,
    shared::{
        entities::Entity,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::CrudService,
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
    users::r#impl::{base::User, permissions::UserOrgPermissions},
};
use anyhow::Error;
use anyhow::Result;
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub struct UserService {
    user_storage: Arc<GenericPostgresStorage<User>>,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<User> for UserService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<User>> {
        &self.user_storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::User
    }
    fn get_network_id(&self, _entity: &User) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, entity: &User) -> Option<Uuid> {
        Some(entity.base.organization_id)
    }

    /// Create a new user
    async fn create(&self, user: User, authentication: AuthenticatedEntity) -> Result<User, Error> {
        let existing_user = self
            .user_storage
            .get_one(EntityFilter::unfiltered().email(&user.base.email))
            .await?;
        if existing_user.is_some() {
            return Err(anyhow::anyhow!(
                "User with email {} already exists",
                user.base.email
            ));
        }

        let created = self.user_storage.create(&User::new(user.base)).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::User,
                entity_id: created.id,
                network_id: self.get_network_id(&created),
                organization_id: self.get_organization_id(&created),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        Ok(created)
    }
}

impl UserService {
    pub fn new(user_storage: Arc<GenericPostgresStorage<User>>, event_bus: Arc<EventBus>) -> Self {
        Self {
            user_storage,
            event_bus,
        }
    }

    pub async fn get_user_by_oidc(&self, oidc_subject: &str) -> Result<Option<User>> {
        let oidc_filter = EntityFilter::unfiltered().oidc_subject(oidc_subject.to_string());
        self.user_storage.get_one(oidc_filter).await
    }

    pub async fn get_organization_owners(&self, organization_id: &Uuid) -> Result<Vec<User>> {
        let filter: EntityFilter = EntityFilter::unfiltered()
            .organization_id(organization_id)
            .user_permissions(&UserOrgPermissions::Owner);

        self.user_storage.get_all(filter).await
    }

    /// Link OIDC to existing user
    pub async fn link_oidc(
        &self,
        user_id: &Uuid,
        oidc_subject: String,
        oidc_provider: String,
    ) -> Result<User> {
        let mut user = self
            .get_by_id(user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        user.base.oidc_provider = Some(oidc_provider);
        user.base.oidc_subject = Some(oidc_subject);
        user.base.oidc_linked_at = Some(chrono::Utc::now());

        self.user_storage.update(&mut user).await?;
        Ok(user)
    }

    /// Unlink OIDC from user (requires password to be set)
    pub async fn unlink_oidc(&self, user_id: &Uuid) -> Result<User> {
        let mut user = self
            .get_by_id(user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        // Require password before unlinking
        if user.base.password_hash.is_none() {
            return Err(anyhow::anyhow!(
                "Cannot unlink OIDC - no password set. Set a password first."
            ));
        }

        user.base.oidc_provider = None;
        user.base.oidc_subject = None;
        user.base.oidc_linked_at = None;
        user.updated_at = chrono::Utc::now();

        self.user_storage.update(&mut user).await?;
        Ok(user)
    }
}
