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
}

pub enum FeatureCheckResult {
    Allowed,
    Denied { message: String },
}

impl FeatureCheckResult {
    pub fn denied(msg: impl Into<String>) -> Self {
        Self::Denied {
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
            return FeatureCheckResult::denied(
                "Your plan does not include team collaboration features",
            );
        }

        // Check seat quota if there's a limit and user doesn't have a plan that lets them buy more seats
        if let Some(max_seats) = ctx.plan.config().included_seats
            && ctx.plan.config().seat_cents.is_none()
        {
            let org_filter = EntityFilter::unfiltered().organization_id(&ctx.organization.id);

            let current_members = ctx
                .app_state
                .services
                .user_service
                .get_all(org_filter)
                .await
                .unwrap_or_default()
                .iter()
                .filter(|u| u.base.permissions.counts_towards_seats())
                .count();

            let pending_invites = ctx
                .app_state
                .services
                .organization_service
                .get_org_invites(&ctx.organization.id)
                .await
                .unwrap_or_default()
                .iter()
                .filter(|i| i.permissions.counts_towards_seats())
                .count();

            let total_seats_used = current_members + pending_invites;

            if total_seats_used >= max_seats as usize {
                return FeatureCheckResult::denied(format!(
                    "Seat limit reached ({}/{}). Upgrade your plan for more seats, or delete any unused pending invites.",
                    total_seats_used, max_seats
                ));
            }
        }

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
