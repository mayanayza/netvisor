use crate::server::{
    auth::middleware::auth::{AuthError, AuthenticatedUser},
    billing::types::base::BillingPlan,
    config::AppState,
    organizations::r#impl::base::Organization,
    shared::{services::traits::CrudService, storage::filter::EntityFilter, types::api::ApiError},
    users::r#impl::permissions::UserOrgPermissions,
};
use async_trait::async_trait;
use axum::{extract::FromRequestParts, http::request::Parts};

/// Context available for feature/quota checks
pub struct FeatureCheckContext<'a> {
    pub organization: &'a Organization,
    pub plan: BillingPlan,
    pub app_state: &'a AppState,
    pub permissions: UserOrgPermissions,
}

pub enum FeatureCheckResult {
    Allowed,
    Denied { message: String },
    PaymentRequired { message: String },
}

impl FeatureCheckResult {
    pub fn denied(msg: impl Into<String>) -> Self {
        Self::Denied {
            message: msg.into(),
        }
    }

    pub fn payment_required(msg: impl Into<String>) -> Self {
        Self::PaymentRequired {
            message: msg.into(),
        }
    }

    pub fn is_allowed(&self) -> bool {
        matches!(self, Self::Allowed)
    }
}

#[async_trait]
pub trait FeatureCheck: Send + Sync + Default {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult;
}

// ============ Extractor ============

pub struct RequireFeature<T: FeatureCheck> {
    pub permissions: UserOrgPermissions,
    pub plan: BillingPlan,
    pub organization: Organization,
    pub _phantom: std::marker::PhantomData<T>,
}

impl<S, T> FromRequestParts<S> for RequireFeature<T>
where
    S: Send + Sync + AsRef<AppState>,
    T: FeatureCheck + Default,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let AuthenticatedUser {
            permissions,
            organization_id,
            ..
        } = AuthenticatedUser::from_request_parts(parts, state).await?;

        let app_state = state.as_ref();

        let organization = app_state
            .services
            .organization_service
            .get_by_id(&organization_id)
            .await
            .map_err(|_| AuthError(ApiError::internal_error("Failed to load organization")))?
            .ok_or_else(|| AuthError(ApiError::forbidden("Organization not found")))?;

        let plan = organization.base.plan.unwrap_or_default();

        let ctx = FeatureCheckContext {
            organization: &organization,
            plan,
            app_state,
            permissions,
        };

        let checker = T::default();
        match checker.check(&ctx).await {
            FeatureCheckResult::Allowed => Ok(RequireFeature {
                permissions,
                plan,
                organization,
                _phantom: std::marker::PhantomData,
            }),
            FeatureCheckResult::Denied { message } => Err(AuthError(ApiError::forbidden(&message))),
            FeatureCheckResult::PaymentRequired { message } => {
                Err(AuthError(ApiError::payment_required(&message)))
            }
        }
    }
}

// ============ Concrete Checkers ============

#[derive(Default)]
pub struct InviteUsersFeature;

#[async_trait]
impl FeatureCheck for InviteUsersFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        let features = ctx.plan.features();

        if !features.share_views {
            return FeatureCheckResult::denied("Your plan does not include inviting users");
        }

        // Seat check happens in the handler where we have access to the request body
        FeatureCheckResult::Allowed
    }
}

#[derive(Default)]
pub struct CreateNetworkFeature;

#[async_trait]
impl FeatureCheck for CreateNetworkFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        // Check networks quota if there's a limit and user doesn't have a plan that lets them buy more networks
        if let Some(max_networks) = ctx.plan.config().included_networks
            && ctx.plan.config().network_cents.is_none()
        {
            let org_filter = EntityFilter::unfiltered().organization_id(&ctx.organization.id);

            let current_networks = ctx
                .app_state
                .services
                .network_service
                .get_all(org_filter)
                .await
                .map(|o| o.len())
                .unwrap_or(0);

            if current_networks >= max_networks as usize {
                return FeatureCheckResult::denied(format!(
                    "Network limit reached ({}/{}). Upgrade your plan for more networks.",
                    current_networks, max_networks
                ));
            }
        }

        FeatureCheckResult::Allowed
    }
}

/// Feature check that verifies the organization has an active billing plan.
///
/// Exemptions:
/// - Community plan (free tier, doesn't require Stripe)
/// - CommercialSelfHosted plan (self-hosted, billing disabled)
/// - Demo plan (demo accounts)
/// - Self-hosted instances (when stripe_secret is None in config)
///
/// Blocks immediately for:
/// - past_due subscription status (no grace period)
/// - Missing plan_status when billing is enabled and plan requires it
#[derive(Default)]
pub struct ActivePlanFeature;

#[async_trait]
impl FeatureCheck for ActivePlanFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        // Self-hosted instances with billing disabled are always allowed
        // (unless enforce_billing_for_testing is set for integration tests)
        let billing_enabled = ctx.app_state.config.stripe_secret.is_some()
            || ctx.app_state.config.enforce_billing_for_testing;
        if !billing_enabled {
            return FeatureCheckResult::Allowed;
        }

        // Check plan type - some plans are exempt
        match &ctx.plan {
            BillingPlan::Community(_)
            | BillingPlan::CommercialSelfHosted(_)
            | BillingPlan::Demo(_) => {
                return FeatureCheckResult::Allowed;
            }
            _ => {}
        }

        // Check subscription status
        match ctx.organization.base.plan_status.as_deref() {
            Some("active") | Some("trialing") => FeatureCheckResult::Allowed,
            Some("past_due") => FeatureCheckResult::payment_required(
                "Your subscription is past due. Please update your payment method.",
            ),
            Some("canceled") => FeatureCheckResult::payment_required(
                "Your subscription has been canceled. Please renew to continue.",
            ),
            _ => FeatureCheckResult::payment_required(
                "Active billing plan required. Please select a plan.",
            ),
        }
    }
}

/// Feature check that blocks non-owner users on demo organizations.
///
/// Demo mode allows users to explore the UI without making destructive changes.
/// Owners of demo organizations retain full access to all features.
#[derive(Default)]
pub struct BlockedInDemoMode;

#[async_trait]
impl FeatureCheck for BlockedInDemoMode {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        // Allow if not demo plan
        if !matches!(ctx.plan, BillingPlan::Demo(_)) {
            return FeatureCheckResult::Allowed;
        }

        // Allow owners full access
        if ctx.permissions == UserOrgPermissions::Owner {
            return FeatureCheckResult::Allowed;
        }

        // Block non-owners on demo plan
        FeatureCheckResult::denied("This action is disabled in demo mode")
    }
}
