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
    #[default]
    ShareViews,
    OnboardingCall,
    DedicatedSupportChannel,
    CommercialLicense,
    AuditLogs,
    ApiAccess,
    RemovePoweredBy,
}

impl HasId for Feature {
    fn id(&self) -> &'static str {
        match self {
            Feature::ApiAccess => "api_access",
            Feature::AuditLogs => "audit_logs",
            Feature::ShareViews => "share_views",
            Feature::OnboardingCall => "onboarding_call",
            Feature::DedicatedSupportChannel => "dedicated_support_channel",
            Feature::CommercialLicense => "commercial_license",
            Feature::RemovePoweredBy => "remove_powered_by",
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
    fn category(&self) -> &'static str {
        match self {
            Feature::OnboardingCall
            | Feature::DedicatedSupportChannel
            | Feature::CommercialLicense => "Support & Licensing",
            _ => "Features",
        }
    }

    fn name(&self) -> &'static str {
        match self {
            Feature::AuditLogs => "Audit Logs",
            Feature::ApiAccess => "API Access",
            Feature::ShareViews => "Share Views",
            Feature::OnboardingCall => "Onboarding Call",
            Feature::DedicatedSupportChannel => "Dedicated Discord Channel",
            Feature::CommercialLicense => "Commercial License",
            Feature::RemovePoweredBy => "Remove 'Powered By'",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Feature::AuditLogs => {
                "Comprehensive logs of all access and data modification actions performed in NetVisor"
            }
            Feature::ApiAccess => {
                "Access NetVisor APIs programmatically to bring your data into other applications"
            }
            Feature::ShareViews => "Share live network diagrams with others",
            Feature::OnboardingCall => {
                "30 minute onboarding call to ensure you're getting the most out of NetVisor"
            }
            Feature::DedicatedSupportChannel => {
                "A dedicated discord channel for support and questions"
            }
            Feature::CommercialLicense => "Use NetVisor under a commercial license",
            Feature::RemovePoweredBy => {
                "Remove 'Powered By NetVisor' in bottom right corner of visualization"
            }
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let is_coming_soon = matches!(
            self,
            Feature::ApiAccess | Feature::AuditLogs | Feature::RemovePoweredBy
        );

        serde_json::json!({
            "is_coming_soon": is_coming_soon
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

        let billing_plan_features: HashSet<&str> =
            features_map.keys().map(|s| s.as_str()).collect();

        // Check that every Feature ID exists in BillingPlanFeatures
        for feature_id in &feature_ids {
            assert!(
                billing_plan_features.contains(feature_id),
                "Feature ID '{}' does not exist in BillingPlanFeatures",
                feature_id
            );
        }

        // Check that every BillingPlanFeatures field has a corresponding Feature
        for feature in &billing_plan_features {
            assert!(
                feature_ids.contains(feature),
                "BillingPlanFeatures field '{}' does not have a corresponding Feature variant",
                feature
            );
        }

        // Verify they have the same count
        assert_eq!(
            feature_ids.len(),
            billing_plan_features.len(),
            "Feature enum has {} variants but BillingPlanFeatures has {} fields",
            feature_ids.len(),
            billing_plan_features.len()
        );
    }
}
