use crate::server::users::r#impl::permissions::UserOrgPermissions;
use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateInviteRequest {
    pub expiration_hours: Option<i64>,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
    pub send_to: Option<EmailAddress>,
}
