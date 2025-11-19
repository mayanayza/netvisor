use crate::server::auth::middleware::AuthenticatedEntity;
use crate::server::organizations::r#impl::invites::OrganizationInvite;
use crate::server::shared::entities::Entity;
use crate::server::shared::events::bus::EventBus;
use crate::server::shared::events::types::{EntityEvent, EntityOperation};
use crate::server::{
    organizations::r#impl::{api::CreateInviteRequest, base::Organization},
    shared::{services::traits::CrudService, storage::generic::GenericPostgresStorage},
};
use anyhow::{Error, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use uuid::Uuid;

pub struct OrganizationService {
    storage: Arc<GenericPostgresStorage<Organization>>,
    invites: Arc<RwLock<HashMap<Uuid, OrganizationInvite>>>,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<Organization> for OrganizationService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Organization>> {
        &self.storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Organization
    }
    fn get_network_id(&self, _entity: &Organization) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, entity: &Organization) -> Option<Uuid> {
        Some(entity.id)
    }
}

impl OrganizationService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Organization>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            storage,
            invites: Arc::new(RwLock::new(HashMap::new())),
            event_bus,
        }
    }

    pub async fn get_invite(&self, id: Uuid) -> Result<OrganizationInvite, Error> {
        let invites = self.invites.read().await;

        let invite = invites
            .get(&id)
            .ok_or_else(|| anyhow!("Invalid or expired invite link"))?;

        if !invite.is_valid() {
            return Err(anyhow!("Invite link has expired or reached maximum uses"));
        }

        Ok(invite.clone())
    }

    pub async fn use_invite(&self, id: Uuid) -> Result<Uuid, Error> {
        let mut invites = self.invites.write().await;

        let invite = invites
            .get_mut(&id)
            .ok_or_else(|| anyhow!("Invalid or expired invite link"))?;

        if !invite.is_valid() {
            return Err(anyhow!("Invite link has expired"));
        }

        let organization_id = invite.organization_id;

        let invite = invites
            .remove(&id)
            .ok_or_else(|| anyhow!("Invite not found"))?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::Invite,
                entity_id: invite.id,
                network_id: None,
                organization_id: Some(invite.organization_id),
                operation: EntityOperation::Deleted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication: AuthenticatedEntity::System,
            })
            .await?;

        Ok(organization_id)
    }

    pub async fn cleanup_expired(&self) {
        let mut invites = self.invites.write().await;
        let now = Utc::now();

        invites.retain(|_, invite| invite.expires_at > now);

        tracing::debug!(
            "Cleaned up expired invites. Current count: {}",
            invites.len()
        );
    }

    pub async fn create_invite(
        &self,
        request: CreateInviteRequest,
        organization_id: Uuid,
        user_id: Uuid,
        url: String,
        authentication: AuthenticatedEntity,
    ) -> Result<OrganizationInvite, Error> {
        let expiration_hours = request.expiration_hours.unwrap_or(168); // Default 7 days

        let invite = OrganizationInvite::new(
            organization_id,
            url,
            user_id,
            expiration_hours,
            request.permissions,
        );

        // Store invite
        self.invites.write().await.insert(invite.id, invite.clone());

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::Invite,
                entity_id: invite.id,
                network_id: None,
                organization_id: Some(invite.organization_id),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        Ok(invite)
    }

    /// Revoke a specific invite
    pub async fn revoke_invite(
        &self,
        id: Uuid,
        authentication: AuthenticatedEntity,
    ) -> Result<(), Error> {
        let mut invites = self.invites.write().await;

        let invite = invites
            .remove(&id)
            .ok_or_else(|| anyhow!("Invite not found"))?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::Invite,
                entity_id: invite.id,
                network_id: None,
                organization_id: Some(invite.organization_id),
                operation: EntityOperation::Deleted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        Ok(())
    }

    /// Revoke a specific invite
    pub async fn revoke_org_invites(&self, organization_id: &Uuid) -> Result<(), Error> {
        let mut invites = self.invites.write().await;

        invites.retain(|_, invite| invite.organization_id != *organization_id);

        Ok(())
    }

    /// List all active invites for an organization
    pub async fn list_invites(&self, organization_id: &Uuid) -> Vec<OrganizationInvite> {
        let invites = self.invites.read().await;

        invites
            .values()
            .filter(|invite| invite.organization_id == *organization_id && invite.is_valid())
            .cloned()
            .collect()
    }
}
