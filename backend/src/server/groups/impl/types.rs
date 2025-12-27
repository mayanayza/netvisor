use crate::server::shared::entities::EntityDiscriminants;
use crate::server::shared::types::{
    Color, Icon,
    metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};
use serde::{Deserialize, Serialize};
use strum_macros::{EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;

#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    Hash,
    PartialEq,
    Eq,
    EnumIter,
    IntoStaticStr,
    EnumDiscriminants,
    Default,
    ToSchema,
)]
#[strum_discriminants(derive(IntoStaticStr, EnumIter, Hash, Deserialize, Serialize))]
#[serde(rename_all = "PascalCase")]
pub enum GroupType {
    #[default]
    RequestPath,
    HubAndSpoke,
}

impl HasId for GroupTypeDiscriminants {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for GroupTypeDiscriminants {
    fn color(&self) -> Color {
        match self {
            GroupTypeDiscriminants::RequestPath => EntityDiscriminants::Group.color(),
            GroupTypeDiscriminants::HubAndSpoke => EntityDiscriminants::Group.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            GroupTypeDiscriminants::RequestPath => Icon::Route,
            GroupTypeDiscriminants::HubAndSpoke => Icon::Share2,
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
