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
pub struct EmbedsFeature;

#[async_trait]
impl FeatureCheck for EmbedsFeature {
    async fn check(&self, _ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        // Embed check happens in the handler where we have access to the request body
        FeatureCheckResult::Allowed
    }
}

#[derive(Default)]
pub struct InviteUsersFeature;

#[async_trait]
impl FeatureCheck for InviteUsersFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        if !ctx.plan.can_invite_users() {
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
