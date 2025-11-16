use crate::server::shared::types::metadata::EntityMetadataProvider;
use crate::server::shared::types::metadata::HasId;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use serde::Deserialize;
use serde::Serialize;
use strum::Display;
use strum::EnumIter;
use strum::IntoStaticStr;

#[derive(Debug, Clone, Serialize, Deserialize, EnumIter, IntoStaticStr, Display, Default)]
pub enum Feature {
    MaxNetworks,
    #[default]
    TeamMembers,
    ShareViews,
    OnboardingCall,
    DedicatedSupportChannel,
    CommercialLicense,
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
            Feature::CommercialLicense => "commercial_license",
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
            Feature::DedicatedSupportChannel => "Dedicated Discord Channel",
            Feature::CommercialLicense => "Commercial License",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Feature::MaxNetworks => "How many networks your organization can create",
            // Feature::ApiAccess => "Access NetVisor APIs programmatically to bring your data into other applications",
            Feature::TeamMembers => "Collaborate on networks with team members and customers",
            Feature::ShareViews => "Share live network diagrams with others",
            Feature::OnboardingCall => {
                "30 minute onboarding call to ensure you're getting the most out of NetVisor"
            }
            Feature::DedicatedSupportChannel => {
                "A dedicated discord channel for support and questions"
            }
            Feature::CommercialLicense => "Use NetVisor under a commercial license",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let use_null_as_unlimited = matches!(self, Feature::MaxNetworks);

        serde_json::json!({
            "use_null_as_unlimited": use_null_as_unlimited
        })
    }
}
