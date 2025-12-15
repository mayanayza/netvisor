//! Billing middleware that checks subscription status for user-authenticated requests.
//!
//! This middleware examines each request and:
//! - For user requests (session-based auth): Checks billing status, returns 402 if not active
//! - For daemon requests (API key auth): Passes through (daemons operate on behalf of orgs)
//! - For unauthenticated requests: Passes through (handler auth will reject if needed)
//!
//! Exemptions (always allowed regardless of billing):
//! - Community plan
//! - CommercialSelfHosted plan
//! - Demo plan
//! - Self-hosted instances (no stripe_secret configured)

use crate::server::{
    billing::types::base::BillingPlan,
    config::AppState,
    shared::{services::traits::CrudService, types::api::ApiError},
};
use axum::{
    body::Body,
    extract::State,
    http::{Request, StatusCode},
    middleware::Next,
    response::{IntoResponse, Response},
};
use std::sync::Arc;
use tower_sessions::Session;
use uuid::Uuid;

/// Middleware that enforces billing requirements for user-authenticated requests.
///
/// Apply this middleware at the router level to groups of routes that require billing.
/// Daemon requests pass through without billing checks.
pub async fn require_billing_for_users(
    State(state): State<Arc<AppState>>,
    request: Request<Body>,
    next: Next,
) -> Response {
    // Check if billing is enabled:
    // - Production: enabled when stripe_secret is configured
    // - Testing: enabled when enforce_billing_for_testing is true
    let billing_enabled =
        state.config.stripe_secret.is_some() || state.config.enforce_billing_for_testing;
    if !billing_enabled {
        return next.run(request).await;
    }

    // Check if this is a daemon request (has Authorization header with Bearer token + X-Daemon-ID)
    let has_daemon_auth = request
        .headers()
        .get(axum::http::header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok())
        .map(|s| s.starts_with("Bearer "))
        .unwrap_or(false)
        && request.headers().get("X-Daemon-ID").is_some();

    if has_daemon_auth {
        // Daemon requests are exempt from billing checks
        return next.run(request).await;
    }

    // Check if this is a user request (has session with user_id)
    // Access session from request extensions (set by SessionManagerLayer)
    let session = request.extensions().get::<Session>().cloned();

    let Some(session) = session else {
        // No session - not a user request, pass through (handler will auth)
        return next.run(request).await;
    };

    let user_id: Option<Uuid> = session.get("user_id").await.ok().flatten();

    let Some(user_id) = user_id else {
        // No user_id in session - not authenticated, pass through
        return next.run(request).await;
    };

    // Get user's organization
    let user = match state.services.user_service.get_by_id(&user_id).await {
        Ok(Some(user)) => user,
        Ok(None) => {
            // User not found - pass through, handler auth will reject
            return next.run(request).await;
        }
        Err(_) => {
            return ApiError::internal_error("Failed to load user").into_response();
        }
    };

    let organization = match state
        .services
        .organization_service
        .get_by_id(&user.base.organization_id)
        .await
    {
        Ok(Some(org)) => org,
        Ok(None) => {
            return ApiError::internal_error("Organization not found").into_response();
        }
        Err(_) => {
            return ApiError::internal_error("Failed to load organization").into_response();
        }
    };

    let plan = organization.base.plan.unwrap_or_default();

    // Check plan type - some plans are exempt from billing checks
    match &plan {
        BillingPlan::Community(_) | BillingPlan::CommercialSelfHosted(_) | BillingPlan::Demo(_) => {
            return next.run(request).await;
        }
        _ => {}
    }

    // Check subscription status
    match organization.base.plan_status.as_deref() {
        Some("active") | Some("trialing") => {
            // Active subscription - allow request
            next.run(request).await
        }
        Some("past_due") => billing_error_response(
            "Your subscription is past due. Please update your payment method.",
        ),
        Some("canceled") => {
            billing_error_response("Your subscription has been canceled. Please renew to continue.")
        }
        _ => billing_error_response("Active billing plan required. Please select a plan."),
    }
}

fn billing_error_response(message: &str) -> Response {
    (
        StatusCode::PAYMENT_REQUIRED,
        axum::Json(serde_json::json!({
            "success": false,
            "error": {
                "code": 402,
                "message": message
            }
        })),
    )
        .into_response()
}
