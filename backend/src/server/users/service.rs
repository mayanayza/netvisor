use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
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
use sqlx::PgPool;
use std::sync::Arc;
use uuid::Uuid;

pub struct UserService {
    user_storage: Arc<GenericPostgresStorage<User>>,
    event_bus: Arc<EventBus>,
    pool: PgPool,
}

impl EventBusService<User> for UserService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, _entity: &User) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, entity: &User) -> Option<Uuid> {
        Some(entity.base.organization_id)
    }
}

#[async_trait]
impl CrudService<User> for UserService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<User>> {
        &self.user_storage
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
        let trigger_stale = created.triggers_staleness(None);

        let metadata = serde_json::json!({
            "trigger_stale": trigger_stale
        });

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: created.id,
                network_id: self.get_network_id(&created),
                organization_id: self.get_organization_id(&created),
                entity_type: created.clone().into(),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata,
                authentication,
            })
            .await?;

        Ok(created)
    }
}

impl UserService {
    pub fn new(
        user_storage: Arc<GenericPostgresStorage<User>>,
        event_bus: Arc<EventBus>,
        pool: PgPool,
    ) -> Self {
        Self {
            user_storage,
            event_bus,
            pool,
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

    /// Get network_ids for a user from the user_network_access junction table
    pub async fn get_network_ids(&self, user_id: &Uuid) -> Result<Vec<Uuid>> {
        let network_ids: Vec<Uuid> =
            sqlx::query_scalar("SELECT network_id FROM user_network_access WHERE user_id = $1")
                .bind(user_id)
                .fetch_all(&self.pool)
                .await?;

        Ok(network_ids)
    }

    /// Set network_ids for a user - replaces all existing entries in user_network_access
    pub async fn set_network_ids(&self, user_id: &Uuid, network_ids: &[Uuid]) -> Result<()> {
        // Delete existing entries
        sqlx::query("DELETE FROM user_network_access WHERE user_id = $1")
            .bind(user_id)
            .execute(&self.pool)
            .await?;

        // Insert new entries
        for network_id in network_ids {
            sqlx::query("INSERT INTO user_network_access (user_id, network_id) VALUES ($1, $2)")
                .bind(user_id)
                .bind(network_id)
                .execute(&self.pool)
                .await?;
        }

        Ok(())
    }

    /// Add a network_id to a user's access
    pub async fn add_network_access(&self, user_id: &Uuid, network_id: &Uuid) -> Result<()> {
        sqlx::query(
            "INSERT INTO user_network_access (user_id, network_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        )
        .bind(user_id)
        .bind(network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    /// Remove a network_id from a user's access
    pub async fn remove_network_access(&self, user_id: &Uuid, network_id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM user_network_access WHERE user_id = $1 AND network_id = $2")
            .bind(user_id)
            .bind(network_id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}
