use serde::{Deserialize, Serialize};

use crate::server::users::r#impl::permissions::UserOrgPermissions;

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateInviteRequest {
    pub url: String,
    pub expiration_hours: Option<i64>,
    pub permissions: UserOrgPermissions,
}
