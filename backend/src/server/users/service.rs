use crate::server::{
    shared::{
        services::traits::CrudService,
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
    users::r#impl::{
        base::{User, UserBase},
        permissions::UserOrgPermissions,
    },
};
use anyhow::Error;
use anyhow::Result;
use async_trait::async_trait;
use email_address::EmailAddress;
use std::sync::Arc;
use uuid::Uuid;

pub struct UserService {
    user_storage: Arc<GenericPostgresStorage<User>>,
}

#[async_trait]
impl CrudService<User> for UserService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<User>> {
        &self.user_storage
    }
}

impl UserService {
    pub fn new(user_storage: Arc<GenericPostgresStorage<User>>) -> Self {
        Self { user_storage }
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

    /// Create a new user
    pub async fn create_user(&self, user: User) -> Result<User, Error> {
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

        self.user_storage.create(&User::new(user.base)).await
    }

    /// Create new user with OIDC (no password)
    pub async fn create_user_with_oidc(
        &self,
        email: EmailAddress,
        oidc_subject: String,
        oidc_provider: Option<String>,
        organization_id: Uuid,
        permissions: Option<UserOrgPermissions>,
    ) -> Result<User, Error> {
        let permissions = permissions.unwrap_or(UserOrgPermissions::Owner);
        let user = User::new(UserBase::new_oidc(
            email,
            oidc_subject,
            oidc_provider,
            organization_id,
            permissions,
        ));

        self.create_user(user).await
    }

    /// Create new user with password (no OIDC)
    pub async fn create_user_with_password(
        &self,
        email: EmailAddress,
        password_hash: String,
        organization_id: Uuid,
        permissions: Option<UserOrgPermissions>,
    ) -> Result<User, Error> {
        let permissions = permissions.unwrap_or(UserOrgPermissions::Owner);
        let user = User::new(UserBase::new_password(
            email,
            password_hash,
            organization_id,
            permissions,
        ));

        self.create_user(user).await
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
