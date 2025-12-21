use serde::{Deserialize, Serialize};
use uuid::Uuid;

use super::base::{EmbedOptions, Share, ShareType};

#[derive(Debug, Clone, Deserialize)]
pub struct CreateUpdateShareRequest {
    pub share: Share,
    pub password: Option<String>,
}

/// Public share metadata (returned without authentication)
#[derive(Debug, Clone, Serialize)]
pub struct PublicShareMetadata {
    pub id: Uuid,
    pub name: String,
    pub share_type: ShareType,
    pub requires_password: bool,
    pub embed_options: EmbedOptions,
}

impl From<&Share> for PublicShareMetadata {
    fn from(share: &Share) -> Self {
        Self {
            id: share.id,
            name: share.base.name.clone(),
            share_type: share.base.share_type,
            requires_password: share.requires_password(),
            embed_options: share.base.embed_options.clone(),
        }
    }
}

/// Share with topology data (returned after authentication/verification)
#[derive(Debug, Clone, Serialize)]
pub struct ShareWithTopology {
    pub share: PublicShareMetadata,
    pub topology: serde_json::Value,
}
