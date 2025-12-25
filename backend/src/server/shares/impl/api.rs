use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use super::base::{Share, ShareOptions};

#[derive(Debug, Clone, Deserialize, ToSchema)]
pub struct CreateUpdateShareRequest {
    pub share: Share,
    pub password: Option<String>,
}

/// Public share metadata (returned without authentication)
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct PublicShareMetadata {
    pub id: Uuid,
    pub name: String,
    pub requires_password: bool,
    pub options: ShareOptions,
}

impl From<&Share> for PublicShareMetadata {
    fn from(share: &Share) -> Self {
        Self {
            id: share.id,
            name: share.base.name.clone(),
            requires_password: share.requires_password(),
            options: share.base.options.clone(),
        }
    }
}

/// Share with topology data (returned after authentication/verification)
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct ShareWithTopology {
    pub share: PublicShareMetadata,
    pub topology: serde_json::Value,
}
