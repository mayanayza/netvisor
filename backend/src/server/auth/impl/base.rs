use crate::server::users::r#impl::permissions::UserOrgPermissions;
use email_address::EmailAddress;
use std::net::IpAddr;
use uuid::Uuid;

pub struct LoginRegisterParams {
    pub org_id: Option<Uuid>,
    pub permissions: Option<UserOrgPermissions>,
    pub ip: IpAddr,
    pub user_agent: Option<String>,
    pub network_ids: Vec<Uuid>,
}

pub struct ProvisionUserParams {
    pub email: EmailAddress,
    pub password_hash: Option<String>,
    pub oidc_subject: Option<String>,
    pub oidc_provider: Option<String>,
    pub org_id: Option<Uuid>,
    pub permissions: Option<UserOrgPermissions>,
    pub network_ids: Vec<Uuid>,
}
