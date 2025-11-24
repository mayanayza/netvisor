use crate::server::users::r#impl::permissions::UserOrgPermissions;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateInviteRequest {
    pub expiration_hours: Option<i64>,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
}
