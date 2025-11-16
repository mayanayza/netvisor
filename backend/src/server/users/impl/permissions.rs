use serde::{Deserialize, Serialize};
use std::cmp::Ordering;
use strum::{Display, EnumIter, IntoEnumIterator, IntoStaticStr};

use crate::server::shared::{
    entities::Entity,
    types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};

#[derive(
    Debug, Clone, Copy, Serialize, Deserialize, Display, PartialEq, Eq, EnumIter, IntoStaticStr,
)]
pub enum UserOrgPermissions {
    Owner,
    Admin,
    Member,
    Viewer,
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
        Entity::User.color()
    }

    fn icon(&self) -> &'static str {
        Entity::User.icon()
    }
}

impl TypeMetadataProvider for UserOrgPermissions {
    fn description(&self) -> &'static str {
        match self {
            UserOrgPermissions::Owner => {
                "Can delete + invite Admins, manage billing in addition to Admin permissions"
            }
            UserOrgPermissions::Admin => {
                "Can delete Members + invite Members in addition to Member privileges"
            }
            UserOrgPermissions::Member => {
                "Can delete Viewers + invite Viewers, read and write all entities (hosts, subnets, etc)"
            }
            UserOrgPermissions::Viewer => "Can view topology",
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
        let can_manage: Vec<UserOrgPermissions> = match self {
            UserOrgPermissions::Owner => UserOrgPermissions::iter().collect(),
            _ => UserOrgPermissions::iter().filter(|p| p < self).collect(),
        };

        serde_json::json!({
            "can_manage": can_manage
        })
    }
}
