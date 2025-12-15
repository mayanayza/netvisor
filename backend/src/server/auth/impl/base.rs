use crate::server::users::r#impl::permissions::UserOrgPermissions;
use chrono::{DateTime, Utc};
use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
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
    pub terms_accepted_at: Option<DateTime<Utc>>,
    /// Whether billing is enabled (if false, sets default billing plan for self-hosted)
    pub billing_enabled: bool,
}

/// Setup data collected before registration (org name, network name, seed preference)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PendingSetup {
    pub org_name: String,
    pub network_name: String,
    pub network_id: Uuid,
    pub seed_data: bool,
}

/// Daemon setup data collected before registration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PendingDaemonSetup {
    pub daemon_name: String,
    pub api_key_raw: String,
}
