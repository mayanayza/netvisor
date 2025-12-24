use crate::server::{
    billing::types::features::Feature,
    shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};
use serde::{Deserialize, Serialize};
use std::hash::Hash;
use stripe_product::price::CreatePriceRecurringInterval;
use strum::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;

#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    Display,
    IntoStaticStr,
    EnumIter,
    EnumDiscriminants,
    Eq,
    ToSchema,
)]
#[strum_discriminants(derive(IntoStaticStr, Serialize))]
#[serde(tag = "type")]
pub enum BillingPlan {
    Community(PlanConfig),
    Starter(PlanConfig),
    Pro(PlanConfig),
    Team(PlanConfig),
    Business(PlanConfig),
    Enterprise(PlanConfig),
    Demo(PlanConfig),
    CommercialSelfHosted(PlanConfig),
}

impl PartialEq for BillingPlan {
    fn eq(&self, other: &Self) -> bool {
        self.config() == other.config()
    }
}

impl Hash for BillingPlan {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.config().hash(state);
    }
}

impl Default for BillingPlan {
    fn default() -> Self {
        #[cfg(feature = "commercial")]
        {
            BillingPlan::CommercialSelfHosted(PlanConfig {
                base_cents: 0,
                rate: BillingRate::Month,
                trial_days: 0,
                seat_cents: None,
                network_cents: None,
                included_networks: None,
                included_seats: None,
            })
        }
        #[cfg(not(feature = "commercial"))]
        {
            BillingPlan::Community(PlanConfig {
                base_cents: 0,
                rate: BillingRate::Month,
                trial_days: 0,
                seat_cents: None,
                network_cents: None,
                included_networks: None,
                included_seats: None,
            })
        }
    }
}

impl BillingPlan {
    pub fn to_yearly(&self, discount: f32) -> Self {
        let mut yearly_config = self.config();
        yearly_config.rate = BillingRate::Year;

        // Round to nearest dollar (100 cents)
        yearly_config.base_cents =
            Self::round_to_dollar(yearly_config.base_cents as f32 * 12.0 * (1.0 - discount));
        yearly_config.seat_cents = yearly_config
            .seat_cents
            .map(|c| Self::round_to_dollar(c as f32 * 12.0 * (1.0 - discount)));
        yearly_config.network_cents = yearly_config
            .network_cents
            .map(|c| Self::round_to_dollar(c as f32 * 12.0 * (1.0 - discount)));

        let mut yearly_plan = *self;
        yearly_plan.set_config(yearly_config);
        yearly_plan
    }
    fn round_to_dollar(cents: f32) -> i64 {
        ((cents / 100.0).round() * 100.0) as i64
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Copy, PartialEq, Eq, Default, Hash, ToSchema)]
pub struct PlanConfig {
    pub base_cents: i64,
    pub rate: BillingRate,
    pub trial_days: u32,

    // None = can't pay for more
    pub seat_cents: Option<i64>,
    pub network_cents: Option<i64>,

    // None = unlimited
    pub included_seats: Option<u64>,
    pub included_networks: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Display, Copy, PartialEq, Eq, Default, Hash)]
pub enum Hosting {
    SelfHosted,
    Managed,
    #[default]
    Cloud,
}

#[derive(Debug, Clone, Serialize, Deserialize, Display, Default, Copy, PartialEq, Eq, Hash, ToSchema)]
pub enum BillingRate {
    #[default]
    Month,
    Year,
}

impl BillingRate {
    pub fn stripe_recurring_interval(&self) -> CreatePriceRecurringInterval {
        match self {
            BillingRate::Month => CreatePriceRecurringInterval::Month,
            BillingRate::Year => CreatePriceRecurringInterval::Year,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BillingPlanFeatures {
    pub share_views: bool,
    pub remove_created_with: bool,
    pub audit_logs: bool,
    pub webhooks: bool,
    pub onboarding_call: bool,
    pub commercial_license: bool,
    pub custom_sso: bool,
    pub managed_deployment: bool,
    pub whitelabeling: bool,
    pub live_chat_support: bool,
    pub embeds: bool,
    pub email_support: bool,
    pub community_support: bool,
    pub priority_support: bool,
}

impl BillingPlan {
    pub fn config(&self) -> PlanConfig {
        match self {
            BillingPlan::Community(plan_config) => *plan_config,
            BillingPlan::Starter(plan_config) => *plan_config,
            BillingPlan::Pro(plan_config) => *plan_config,
            BillingPlan::Team(plan_config) => *plan_config,
            BillingPlan::Business(plan_config) => *plan_config,
            BillingPlan::Enterprise(plan_config) => *plan_config,
            BillingPlan::Demo(plan_config) => *plan_config,
            BillingPlan::CommercialSelfHosted(plan_config) => *plan_config,
        }
    }

    pub fn set_config(&mut self, config: PlanConfig) {
        match self {
            BillingPlan::Community(plan_config) => *plan_config = config,
            BillingPlan::Starter(plan_config) => *plan_config = config,
            BillingPlan::Pro(plan_config) => *plan_config = config,
            BillingPlan::Team(plan_config) => *plan_config = config,
            BillingPlan::Business(plan_config) => *plan_config = config,
            BillingPlan::Enterprise(plan_config) => *plan_config = config,
            BillingPlan::Demo(plan_config) => *plan_config = config,
            BillingPlan::CommercialSelfHosted(plan_config) => *plan_config = config,
        }
    }

    pub fn is_commercial(&self) -> bool {
        matches!(
            self,
            BillingPlan::Team(_)
                | BillingPlan::Business(_)
                | BillingPlan::Enterprise(_)
                | BillingPlan::CommercialSelfHosted(_)
                | BillingPlan::Demo(_)
        )
    }

    pub fn is_demo(&self) -> bool {
        matches!(self, BillingPlan::Demo(_))
    }

    pub fn can_invite_users(&self) -> bool {
        self.config().included_seats.unwrap_or(u64::MAX) > 1 && self.config().seat_cents.is_some()
    }

    pub fn hosting(&self) -> Hosting {
        match self {
            BillingPlan::Community(_) => Hosting::SelfHosted,
            BillingPlan::CommercialSelfHosted(_) => Hosting::SelfHosted,
            BillingPlan::Enterprise(_) => Hosting::Managed,
            _ => Hosting::Cloud,
        }
    }

    pub fn custom_price(&self) -> Option<&str> {
        match self {
            BillingPlan::Enterprise(_) => Some("Custom"),
            BillingPlan::Community(_) => Some("Free"),
            BillingPlan::CommercialSelfHosted(_) => Some("Custom"),
            _ => None,
        }
    }

    pub fn stripe_product_id(&self) -> String {
        self.to_string().to_lowercase()
    }

    pub fn stripe_base_price_lookup_key(&self) -> String {
        format!(
            "{}_{}_{}",
            self.stripe_product_id(),
            self.config().base_cents,
            self.config().rate
        )
    }

    pub fn stripe_seat_addon_price_lookup_key(&self) -> Option<String> {
        self.config().seat_cents.map(|c| {
            format!(
                "{}_seats_{}_{}",
                self.stripe_product_id(),
                c,
                self.config().rate
            )
        })
    }

    pub fn stripe_network_addon_price_lookup_key(&self) -> Option<String> {
        self.config().network_cents.map(|c| {
            format!(
                "{}_networks_{}_{}",
                self.stripe_product_id(),
                c,
                self.config().rate
            )
        })
    }

    pub fn features(&self) -> BillingPlanFeatures {
        match self {
            BillingPlan::Community { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: false,
                webhooks: false,
                audit_logs: false,
                commercial_license: false,
                remove_created_with: false,
                custom_sso: false,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: true,
                email_support: false,
                community_support: true,
                priority_support: false,
            },
            BillingPlan::Starter { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: false,
                commercial_license: false,
                webhooks: false,
                audit_logs: false,
                remove_created_with: true,
                custom_sso: false,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: false,
                email_support: true,
                community_support: false,
                priority_support: false,
            },
            BillingPlan::Pro { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: false,
                commercial_license: false,
                webhooks: false,
                audit_logs: false,
                remove_created_with: true,
                custom_sso: false,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: true,
                email_support: true,
                community_support: false,
                priority_support: false,
            },
            BillingPlan::Team { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: true,
                commercial_license: true,
                webhooks: false,
                audit_logs: false,
                remove_created_with: true,
                custom_sso: false,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: true,
                email_support: true,
                community_support: false,
                priority_support: true,
            },
            BillingPlan::Business { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: true,
                commercial_license: true,
                webhooks: true,
                audit_logs: true,
                remove_created_with: true,
                custom_sso: false,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: true,
                email_support: true,
                community_support: false,
                priority_support: true,
            },
            BillingPlan::Enterprise { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: true,
                commercial_license: true,
                webhooks: true,
                audit_logs: true,
                remove_created_with: true,
                custom_sso: true,
                managed_deployment: true,
                whitelabeling: true,
                live_chat_support: true,
                embeds: true,
                email_support: true,
                community_support: false,
                priority_support: true,
            },
            BillingPlan::Demo { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: true,
                commercial_license: true,
                webhooks: true,
                audit_logs: true,
                remove_created_with: true,
                custom_sso: true,
                managed_deployment: true,
                whitelabeling: true,
                live_chat_support: true,
                embeds: true,
                email_support: true,
                community_support: true,
                priority_support: true,
            },
            BillingPlan::CommercialSelfHosted { .. } => BillingPlanFeatures {
                share_views: true,
                onboarding_call: true,
                commercial_license: true,
                webhooks: true,
                audit_logs: true,
                remove_created_with: true,
                custom_sso: true,
                managed_deployment: false,
                whitelabeling: false,
                live_chat_support: false,
                embeds: true,
                email_support: true,
                community_support: false,
                priority_support: true,
            },
        }
    }
}

#[allow(clippy::from_over_into)]
impl Into<Vec<Feature>> for BillingPlanFeatures {
    fn into(self) -> Vec<Feature> {
        let mut features = vec![];

        let BillingPlanFeatures {
            share_views,
            onboarding_call,
            commercial_license,
            webhooks,
            audit_logs,
            remove_created_with,
            custom_sso,
            managed_deployment,
            whitelabeling,
            live_chat_support,
            embeds,
            email_support,
            priority_support,
            community_support,
        } = self;

        if share_views {
            features.push(Feature::ShareViews)
        }

        if custom_sso {
            features.push(Feature::CustomSso)
        }

        if managed_deployment {
            features.push(Feature::ManagedDeployment)
        }

        if embeds {
            features.push(Feature::Embeds)
        }

        if whitelabeling {
            features.push(Feature::Whitelabeling)
        }

        if live_chat_support {
            features.push(Feature::LiveChatSupport)
        }

        if priority_support {
            features.push(Feature::PrioritySupport)
        }

        if community_support {
            features.push(Feature::CommunitySupport)
        }

        if email_support {
            features.push(Feature::EmailSupport)
        }

        if onboarding_call {
            features.push(Feature::OnboardingCall)
        }

        if commercial_license {
            features.push(Feature::CommercialLicense)
        }

        if webhooks {
            features.push(Feature::Webhooks);
        }

        if audit_logs {
            features.push(Feature::AuditLogs)
        }

        if remove_created_with {
            features.push(Feature::RemoveCreatedWith)
        }

        features
    }
}

impl HasId for BillingPlan {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for BillingPlan {
    fn icon(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => "Heart",
            BillingPlan::Starter { .. } => "ThumbsUp",
            BillingPlan::Pro { .. } => "Zap",
            BillingPlan::Team { .. } => "Users",
            BillingPlan::Business { .. } => "Briefcase",
            BillingPlan::Enterprise { .. } => "Building",
            BillingPlan::Demo { .. } => "TestTube",
            BillingPlan::CommercialSelfHosted { .. } => "ServerCog",
        }
    }

    fn color(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => "pink",
            BillingPlan::Starter { .. } => "blue",
            BillingPlan::Pro { .. } => "yellow",
            BillingPlan::Team { .. } => "orange",
            BillingPlan::Business { .. } => "indigo",
            BillingPlan::Enterprise { .. } => "teal",
            BillingPlan::Demo { .. } => "purple",
            BillingPlan::CommercialSelfHosted { .. } => "gray",
        }
    }
}

impl TypeMetadataProvider for BillingPlan {
    fn name(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => "Community",
            BillingPlan::Starter { .. } => "Starter",
            BillingPlan::Pro { .. } => "Pro",
            BillingPlan::Team { .. } => "Team",
            BillingPlan::Business { .. } => "Business",
            BillingPlan::Enterprise { .. } => "Enterprise",
            BillingPlan::Demo { .. } => "Demo",
            BillingPlan::CommercialSelfHosted { .. } => "On-Premise",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => {
                "Community plan for individuals self-hosting Scanopy - full control over configuration and integrations"
            }
            BillingPlan::Starter { .. } => {
                "Automatically create living documentation of your network"
            }
            BillingPlan::Pro { .. } => "Visualize multiple networks and share network diagrams",
            BillingPlan::Team { .. } => {
                "Collaborate on infrastructure documentation with your team"
            }
            BillingPlan::Business { .. } => {
                "Manage multi-site and multi-customer documentation with advanced features"
            }
            BillingPlan::Enterprise { .. } => {
                "Fully managed Scanopy with dedicated support and custom deployment"
            }
            BillingPlan::Demo { .. } => "Demo mode",
            BillingPlan::CommercialSelfHosted { .. } => {
                "Commercial license for self-managed deployments — full control over configuration and integrations"
            }
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let config = self.config();

        serde_json::json!({
            // Pricing information
            "base_cents": config.base_cents,
            "rate": config.rate,
            "trial_days": config.trial_days,
            "seat_cents": config.seat_cents,
            "network_cents": config.network_cents,
            "included_seats": config.included_seats,
            "included_networks": config.included_networks,
            // Feature flags and metadata
            "features": self.features(),
            "is_commercial": self.is_commercial(),
            "hosting": self.hosting(),
            "custom_price": self.custom_price()
        })
    }
}
