use serde::{Deserialize, Serialize};
use std::fmt::Display;
use stripe_product::price::CreatePriceRecurringInterval;
use strum::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};

#[derive(
    Debug, Clone, Copy, Serialize, Deserialize, Display, IntoStaticStr, EnumIter, EnumDiscriminants,
)]
#[serde(tag = "type")]
pub enum BillingPlan {
    Community { price: Price, trial_days: u32 },
    Starter { price: Price, trial_days: u32 },
    Pro { price: Price, trial_days: u32 },
    Team { price: Price, trial_days: u32 },
}

impl PartialEq for BillingPlan {
    fn eq(&self, other: &Self) -> bool {
        self.price() == other.price() && self.trial_days() == other.trial_days()
    }
}

impl Default for BillingPlan {
    fn default() -> Self {
        BillingPlan::Community {
            price: Price {
                cents: 0,
                rate: BillingRate::Month,
            },
            trial_days: 0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, Copy)]
pub struct Price {
    pub cents: i64,
    pub rate: BillingRate,
}

impl PartialEq for Price {
    fn eq(&self, other: &Self) -> bool {
        self.cents == other.cents && self.rate == other.rate
    }
}

impl Price {
    pub fn stripe_recurring_interval(&self) -> CreatePriceRecurringInterval {
        match self.rate {
            BillingRate::Month => CreatePriceRecurringInterval::Month,
            BillingRate::Year => CreatePriceRecurringInterval::Year,
        }
    }
}

impl Display for Price {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} per {}", self.cents, self.rate)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Display, Default, Copy, PartialEq)]
pub enum BillingRate {
    #[default]
    Month,
    Year,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BillingPlanFeatures {
    pub max_networks: Option<usize>,
    // pub api_access: bool,
    pub team_members: bool,
    pub share_views: bool,
    pub onboarding_call: bool,
    pub dedicated_support_channel: bool,
    pub commercial_license: bool,
}

impl BillingPlan {
    pub fn from_id(id: &str, price: Price, trial_days: u32) -> Option<Self> {
        match id {
            "starter" => Some(Self::Starter { price, trial_days }),
            "pro" => Some(Self::Pro { price, trial_days }),
            "team" => Some(Self::Team { price, trial_days }),
            _ => None,
        }
    }

    pub fn is_business_plan(&self) -> bool {
        matches!(self, BillingPlan::Team { .. })
    }

    pub fn stripe_product_id(&self) -> String {
        self.to_string().to_lowercase()
    }

    pub fn stripe_price_lookup_key(&self) -> String {
        format!(
            "{}_{}_monthly",
            self.stripe_product_id(),
            self.price().to_string().replace(" ", "_").replace(".", "_")
        )
    }

    pub fn price(&self) -> Price {
        match self {
            BillingPlan::Community { price, .. } => *price,
            BillingPlan::Starter { price, .. } => *price,
            BillingPlan::Pro { price, .. } => *price,
            BillingPlan::Team { price, .. } => *price,
        }
    }

    pub fn trial_days(&self) -> u32 {
        match self {
            BillingPlan::Community { trial_days, .. } => *trial_days,
            BillingPlan::Starter { trial_days, .. } => *trial_days,
            BillingPlan::Pro { trial_days, .. } => *trial_days,
            BillingPlan::Team { trial_days, .. } => *trial_days,
        }
    }

    pub fn features(&self) -> BillingPlanFeatures {
        match self {
            Self::Community { .. } => BillingPlanFeatures {
                max_networks: None,
                // api_access: true,
                team_members: true,
                share_views: true,
                onboarding_call: true,
                dedicated_support_channel: true,
                commercial_license: false,
            },
            Self::Starter { .. } => BillingPlanFeatures {
                max_networks: Some(1),
                // api_access: false,
                team_members: false,
                share_views: false,
                onboarding_call: false,
                dedicated_support_channel: false,
                commercial_license: false,
            },
            Self::Pro { .. } => BillingPlanFeatures {
                max_networks: Some(3),
                // api_access: false),
                team_members: false,
                share_views: true,
                onboarding_call: false,
                dedicated_support_channel: false,
                commercial_license: false,
            },
            Self::Team { .. } => BillingPlanFeatures {
                max_networks: None,
                // api_access: true,
                team_members: true,
                share_views: true,
                onboarding_call: true,
                dedicated_support_channel: true,
                commercial_license: true,
            },
        }
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
        }
    }

    fn color(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => "pink",
            BillingPlan::Starter { .. } => "blue",
            BillingPlan::Pro { .. } => "yellow",
            BillingPlan::Team { .. } => "orange",
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
        }
    }

    fn description(&self) -> &'static str {
        match self {
            BillingPlan::Community { .. } => "Community plan for individuals self-hosting NetVisor",
            BillingPlan::Starter { .. } => {
                "Automatically create living documentation of your network"
            }
            BillingPlan::Pro { .. } => "Visualize multiple networks and share network diagrams",
            BillingPlan::Team { .. } => {
                "Collaborate on infrastructure documentation with your team"
            }
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "features": self.features(),
        })
    }
}
