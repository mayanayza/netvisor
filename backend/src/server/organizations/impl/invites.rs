use chrono::{DateTime, Utc};
use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::{
    shared::entities::ChangeTriggersTopologyStaleness,
    users::r#impl::permissions::UserOrgPermissions,
};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct Invite {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
    pub url: String,
    pub created_by: Uuid,
    pub created_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
    pub send_to: Option<EmailAddress>,
}

impl Invite {
    pub fn new(
        organization_id: Uuid,
        url: String,
        created_by: Uuid,
        expiration_hours: i64,
        permissions: UserOrgPermissions,
        network_ids: Vec<Uuid>,
        send_to: Option<EmailAddress>,
    ) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            organization_id,
            permissions,
            network_ids,
            created_by,
            url,
            created_at: now,
            expires_at: now + chrono::Duration::hours(expiration_hours),
            send_to,
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

impl ChangeTriggersTopologyStaleness<Invite> for Invite {
    fn triggers_staleness(&self, _other: Option<Invite>) -> bool {
        false
    }
}
