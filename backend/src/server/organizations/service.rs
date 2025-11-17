use crate::server::organizations::r#impl::invites::OrganizationInvite;
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
    invites: Arc<RwLock<HashMap<String, OrganizationInvite>>>,
}

#[async_trait]
impl CrudService<Organization> for OrganizationService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Organization>> {
        &self.storage
    }
}

impl OrganizationService {
    pub fn new(storage: Arc<GenericPostgresStorage<Organization>>) -> Self {
        Self {
            storage,
            invites: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    pub async fn get_invite(&self, token: &str) -> Result<OrganizationInvite, Error> {
        let invites = self.invites.read().await;

        let invite = invites
            .get(token)
            .ok_or_else(|| anyhow!("Invalid or expired invite link"))?;

        if !invite.is_valid() {
            return Err(anyhow!("Invite link has expired or reached maximum uses"));
        }

        Ok(invite.clone())
    }

    pub async fn use_invite(&self, token: &str) -> Result<Uuid, Error> {
        let mut invites = self.invites.write().await;

        let invite = invites
            .get_mut(token)
            .ok_or_else(|| anyhow!("Invalid or expired invite link"))?;

        if !invite.is_valid() {
            return Err(anyhow!("Invite link has expired"));
        }

        let organization_id = invite.organization_id;

        invites.remove(token);

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
        self.invites
            .write()
            .await
            .insert(invite.token.clone(), invite.clone());

        Ok(invite)
    }

    /// Revoke a specific invite
    pub async fn revoke_invite(&self, token: &str) -> Result<(), Error> {
        let mut invites = self.invites.write().await;

        invites
            .remove(token)
            .ok_or_else(|| anyhow!("Invite not found"))?;

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
