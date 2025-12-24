use serde::{Deserialize, Serialize};
use std::{cmp::Ordering, str::FromStr};
use strum::{Display, EnumIter, IntoEnumIterator, IntoStaticStr};
use ts_rs::TS;
use utoipa::ToSchema;

use crate::server::shared::{
    entities::EntityDiscriminants,
    types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};

#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    Display,
    PartialEq,
    Eq,
    EnumIter,
    IntoStaticStr,
    Hash,
    Default,
    ToSchema,
    TS,
)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub enum UserOrgPermissions {
    Owner,
    Admin,
    Member,
    #[serde(alias = "Visualizer")]
    #[default]
    Viewer,
}

impl UserOrgPermissions {
    pub fn as_str(&self) -> &'static str {
        self.into()
    }
}

impl FromStr for UserOrgPermissions {
    type Err = ();

    fn from_str(input: &str) -> Result<UserOrgPermissions, Self::Err> {
        match input {
            "Owner" => Ok(UserOrgPermissions::Owner),
            "Admin" => Ok(UserOrgPermissions::Admin),
            "Member" => Ok(UserOrgPermissions::Member),
            "Viewer" | "Visualizer" | "None" => Ok(UserOrgPermissions::Viewer),
            _ => Err(()),
        }
    }
}

impl PartialOrd for UserOrgPermissions {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for UserOrgPermissions {
    fn cmp(&self, other: &Self) -> Ordering {
        let self_rank = match self {
            UserOrgPermissions::Owner => 4,
            UserOrgPermissions::Admin => 3,
            UserOrgPermissions::Member => 2,
            UserOrgPermissions::Viewer => 1,
        };

        let other_rank = match other {
            UserOrgPermissions::Owner => 4,
            UserOrgPermissions::Admin => 3,
            UserOrgPermissions::Member => 2,
            UserOrgPermissions::Viewer => 1,
        };

        self_rank.cmp(&other_rank)
    }
}

impl HasId for UserOrgPermissions {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for UserOrgPermissions {
    fn color(&self) -> &'static str {
        EntityDiscriminants::User.color()
    }

    fn icon(&self) -> &'static str {
        EntityDiscriminants::User.icon()
    }
}

impl TypeMetadataProvider for UserOrgPermissions {
    fn description(&self) -> &'static str {
        match self {
            UserOrgPermissions::Owner => {
                "Full organization control: manage billing, invite any role, and access all administrative features"
            }
            UserOrgPermissions::Admin => {
                "Manage users and invites, create and modify all entities, but cannot access billing"
            }
            UserOrgPermissions::Member => "Create and modify entities for specific networks",
            UserOrgPermissions::Viewer => "View entities.",
        }
    }

    fn name(&self) -> &'static str {
        match self {
            UserOrgPermissions::Owner => "Owner",
            UserOrgPermissions::Admin => "Admin",
            UserOrgPermissions::Member => "Member",
            UserOrgPermissions::Viewer => "Viewer",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let can_manage_user_permissions: Vec<UserOrgPermissions> = match self {
            UserOrgPermissions::Owner => UserOrgPermissions::iter().collect(),
            UserOrgPermissions::Admin => UserOrgPermissions::iter().filter(|p| p < self).collect(),
            // Non-admins can't manage permissions
            _ => vec![],
        };

        let manage_org_entities: bool =
            matches!(self, UserOrgPermissions::Owner | UserOrgPermissions::Admin);

        serde_json::json!({
            "can_manage_user_permissions": can_manage_user_permissions,
            "manage_org_entities": manage_org_entities,
        })
    }
}
