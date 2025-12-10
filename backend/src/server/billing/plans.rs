use super::types::base::{BillingPlan, BillingRate, PlanConfig};

/// Returns the canonical list of billing plans for NetVisor.
/// This is the single source of truth for plan definitions.
fn get_default_plans() -> Vec<BillingPlan> {
    vec![
        BillingPlan::Starter(PlanConfig {
            base_cents: 1499,
            rate: BillingRate::Month,
            trial_days: 0,
            seat_cents: None,
            network_cents: None,
            included_seats: Some(1),
            included_networks: Some(1),
        }),
        BillingPlan::Pro(PlanConfig {
            base_cents: 2499,
            rate: BillingRate::Month,
            trial_days: 7,
            seat_cents: None,
            network_cents: None,
            included_seats: Some(1),
            included_networks: Some(3),
        }),
        BillingPlan::Team(PlanConfig {
            base_cents: 7999,
            rate: BillingRate::Month,
            trial_days: 7,
            seat_cents: Some(1000),
            network_cents: Some(800),
            included_seats: Some(5),
            included_networks: Some(5),
        }),
        BillingPlan::Business(PlanConfig {
            base_cents: 14999,
            rate: BillingRate::Month,
            trial_days: 14,
            seat_cents: Some(800),
            network_cents: Some(500),
            included_seats: Some(10),
            included_networks: Some(25),
        }),
    ]
}

// fn get_enterprise_plan() -> BillingPlan {
//     BillingPlan::Enterprise(PlanConfig {
//         base_cents: 0,
//         rate: BillingRate::Month,
//         trial_days: 14,
//         seat_cents: None,
//         network_cents: None,
//         included_seats: None,
//         included_networks: None,
//     })
// }

/// Returns both monthly and yearly versions of all plans.
/// Yearly plans get a 20% discount.
pub fn get_all_plans() -> Vec<BillingPlan> {
    let monthly_plans = get_default_plans();
    let mut all_plans = monthly_plans.clone();

    // Add yearly versions with 20% discount
    for plan in monthly_plans {
        all_plans.push(plan.to_yearly(0.20));
    }

    all_plans
}
