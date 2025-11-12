use serde::Serialize;
use strum::Display;
use strum::EnumIter;
use crate::server::shared::types::metadata::EntityMetadataProvider;
use crate::server::shared::types::metadata::HasId;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use serde::Deserialize;
use strum::IntoStaticStr;

#[derive(Debug, Clone, Serialize, Deserialize, EnumIter, IntoStaticStr, Display)]
pub enum Feature {
    MaxNetworks,
    TeamMembers,
    ShareViews,
    OnboardingCall,
    DedicatedSupportChannel
}

impl Default for Feature {
    fn default() -> Self {
        Feature::TeamMembers
    }
}

impl HasId for Feature {
    fn id(&self) -> &'static str {
        match self {
            Feature::MaxNetworks => "max_networks",
            // Feature::ApiAccess => "API Access",
            Feature::TeamMembers => "team_members",
            Feature::ShareViews => "share_views",
            Feature::OnboardingCall => "onboarding_call",
            Feature::DedicatedSupportChannel => "dedicated_support_channel",
        }
    }
}

impl EntityMetadataProvider for Feature {
    fn color(&self) -> &'static str {
        ""
    }

    fn icon(&self) -> &'static str {
        ""
    }
}

impl TypeMetadataProvider for Feature {
    fn name(&self) -> &'static str {
        match self {
            Feature::MaxNetworks => "Max Networks",
            // Feature::ApiAccess => "API Access",
            Feature::TeamMembers => "Team Members",
            Feature::ShareViews => "Share Views",
            Feature::OnboardingCall => "Onboarding Call",
            Feature::DedicatedSupportChannel => "Dedicated Support Channel",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Feature::MaxNetworks =>  "How many networks your organization can create",
            // Feature::ApiAccess => "Access NetVisor APIs programmatically to bring your data into other applications",
            Feature::TeamMembers => "Collaborate on networks with team members and customers",
            Feature::ShareViews => "Share live network diagrams with others",
            Feature::OnboardingCall => "30 minute onboarding call to ensure you're getting the most out of NetVisor",
            Feature::DedicatedSupportChannel => "A dedicated discord channel for support and questions",
        }
    }

    fn metadata(&self) -> serde_json::Value {

        let use_null_as_unlimited = match self {
            Feature::MaxNetworks => true,
            _ => false
        };

        serde_json::json!({
            "use_null_as_unlimited": use_null_as_unlimited
        })
    }
}
