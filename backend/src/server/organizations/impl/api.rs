use crate::server::users::r#impl::permissions::UserOrgPermissions;
use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct CreateInviteRequest {
    pub expiration_hours: Option<i64>,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
    #[schema(value_type = Option<String>)]
    pub send_to: Option<EmailAddress>,
}
