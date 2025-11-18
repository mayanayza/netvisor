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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::billing::types::base::BillingPlan;
    use std::collections::HashSet;
    use strum::IntoEnumIterator;

    #[test]
    fn test_feature_ids_match_billing_plan_features_fields() {
        // Get all Feature IDs
        let feature_ids: HashSet<&str> = Feature::iter().map(|f| f.id()).collect();

        // Get all keys from BillingPlanFeatures by serializing an instance
        let features = BillingPlan::default().features();
        let features_json = serde_json::to_value(&features).expect("Failed to serialize features");
        let features_map = features_json
            .as_object()
            .expect("Features should be an object");

        let billing_plan_keys: HashSet<&str> = features_map.keys().map(|s| s.as_str()).collect();

        // Check that every Feature ID exists in BillingPlanFeatures
        for feature_id in &feature_ids {
            assert!(
                billing_plan_keys.contains(feature_id),
                "Feature ID '{}' does not exist in BillingPlanFeatures",
                feature_id
            );
        }

        // Check that every BillingPlanFeatures field has a corresponding Feature
        for key in &billing_plan_keys {
            assert!(
                feature_ids.contains(key),
                "BillingPlanFeatures field '{}' does not have a corresponding Feature variant",
                key
            );
        }

        // Verify they have the same count
        assert_eq!(
            feature_ids.len(),
            billing_plan_keys.len(),
            "Feature enum has {} variants but BillingPlanFeatures has {} fields",
            feature_ids.len(),
            billing_plan_keys.len()
        );
    }
}
