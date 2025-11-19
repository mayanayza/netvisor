use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::users::r#impl::permissions::UserOrgPermissions;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrganizationInvite {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
    pub url: String,
    pub created_by: Uuid,
    pub created_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
}

impl OrganizationInvite {
    pub fn new(
        organization_id: Uuid,
        url: String,
        created_by: Uuid,
        expiration_hours: i64,
        permissions: UserOrgPermissions,
    ) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            organization_id,
            permissions,
            created_by,
            url,
            created_at: now,
            expires_at: now + chrono::Duration::hours(expiration_hours),
        }
    }

    pub fn is_valid(&self) -> bool {
        let now = Utc::now();

        // Check expiration
        if now > self.expires_at {
            return false;
        }

        true
    }
}
