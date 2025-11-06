use crate::server::shared::constants::Entity;
use crate::server::shared::types::api::deserialize_empty_string_as_none;
use crate::server::shared::types::entities::EntitySource;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use strum_macros::{EnumDiscriminants, EnumIter, IntoStaticStr};
use uuid::Uuid;
use validator::Validate;

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    Hash,
    PartialEq,
    Eq,
    EnumIter,
    IntoStaticStr,
    EnumDiscriminants,
)]
#[strum_discriminants(derive(IntoStaticStr, EnumIter, Hash, Deserialize, Serialize, Default))]
#[serde(tag = "group_type")]
pub enum GroupType {
    #[strum_discriminants(default)]
    RequestPath {
        service_bindings: Vec<Uuid>,
    },
    HubAndSpoke {
        service_bindings: Vec<Uuid>,
    },
}

#[derive(Debug, Clone, Serialize, Validate, Deserialize)]
pub struct GroupBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub network_id: Uuid,
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    #[validate(length(min = 0, max = 500))]
    pub description: Option<String>,
    #[serde(flatten)]
    pub group_type: GroupType,
    pub source: EntitySource,
    pub color: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: GroupBase,
}

impl Group {
    pub fn new(base: GroupBase) -> Self {
        let now = chrono::Utc::now();
        Self {
            id: uuid::Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }
}

impl HasId for GroupTypeDiscriminants {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for GroupTypeDiscriminants {
    fn color(&self) -> &'static str {
        match self {
            GroupTypeDiscriminants::RequestPath => Entity::Group.color(),
            GroupTypeDiscriminants::HubAndSpoke => Entity::Group.color(),
        }
    }

    fn icon(&self) -> &'static str {
        match self {
            GroupTypeDiscriminants::RequestPath => "Route",
            GroupTypeDiscriminants::HubAndSpoke => "Share2",
        }
    }
}

impl TypeMetadataProvider for GroupTypeDiscriminants {
    fn name(&self) -> &'static str {
        match self {
            GroupTypeDiscriminants::RequestPath => "Request Path",
            GroupTypeDiscriminants::HubAndSpoke => "Hub and Spoke",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            GroupTypeDiscriminants::RequestPath => {
                "Ordered path of network traffic through service bindings. Represents how requests flow through your infrastructure from one service to another."
            }
            GroupTypeDiscriminants::HubAndSpoke => {
                "Central service connecting to multiple dependent services in a hub-and-spoke pattern. The first binding in the list will be used as the hub."
            }
        }
    }
}
