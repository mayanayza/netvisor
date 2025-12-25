use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::billing::types::api::CreateCheckoutRequest;
use crate::server::billing::types::base::BillingPlan;
use crate::server::config::AppState;
use crate::server::shared::types::api::{ApiError, ApiResult};
use crate::server::shared::types::api::{ApiErrorResponse, ApiResponse, EmptyApiResponse};
use axum::Json;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::http::header::CACHE_CONTROL;
use axum::response::IntoResponse;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_billing_plans))
        .routes(routes!(create_checkout_session))
        .routes(routes!(handle_webhook))
        .routes(routes!(create_portal_session))
}

/// Get available billing plans
#[utoipa::path(
    get,
    path = "/plans",
    tags = ["billing", "internal"],
    responses(
        (status = 200, description = "List of available billing plans", body = ApiResponse<Vec<BillingPlan>>),
        (status = 400, description = "Billing not enabled", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn get_billing_plans(
    State(state): State<Arc<AppState>>,
    RequireOwner(_user): RequireOwner,
) -> Result<impl IntoResponse, ApiError> {
    if let Some(billing_service) = state.services.billing_service.clone() {
        let plans = billing_service.get_plans();
        Ok((
            [(CACHE_CONTROL, "no-store, no-cache, must-revalidate")],
            Json(ApiResponse::success(plans)),
        ))
    } else {
        Err(ApiError::bad_request(
            "Billing is not enabled on this server",
        ))
    }
}

/// Create a checkout session
#[utoipa::path(
    post,
    path = "/checkout",
    tags = ["billing", "internal"],
    request_body = CreateCheckoutRequest,
    responses(
        (status = 200, description = "Checkout session URL", body = ApiResponse<String>),
        (status = 400, description = "Invalid plan or billing not enabled", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_checkout_session(
    State(state): State<Arc<AppState>>,
    RequireOwner(_user): RequireOwner,
    user: AuthenticatedUser,
    Json(request): Json<CreateCheckoutRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {
    // Build success/cancel URLs
    let success_url = format!("{}?session_id={{CHECKOUT_SESSION_ID}}", request.url);
    let cancel_url = format!("{}/billing", request.url);

    if let Some(billing_service) = state.services.billing_service.clone() {
        let current_plans = billing_service.get_plans();

        if !current_plans.contains(&request.plan) {
            return Err(ApiError::bad_request("Requested plan is not a valid plan."));
        }

        let session = billing_service
            .create_checkout_session(
                user.organization_id,
                request.plan,
                success_url,
                cancel_url,
                user.into(),
            )
            .await?;

        Ok(Json(ApiResponse::success(session.url.unwrap())))
    } else {
        Err(ApiError::bad_request(
            "Billing is not enabled on this server",
        ))
    }
}

/// Handle Stripe webhook
///
/// Internal endpoint for Stripe webhook callbacks.
#[utoipa::path(
    post,
    path = "/webhooks",
    tags = ["billing", "internal"],
    responses(
        (status = 200, description = "Webhook processed", body = EmptyApiResponse),
        (status = 400, description = "Invalid signature or billing not enabled", body = ApiErrorResponse),
    )
)]
async fn handle_webhook(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    body: String,
) -> ApiResult<Json<ApiResponse<()>>> {
    let signature = headers
        .get("stripe-signature")
        .and_then(|v| v.to_str().ok())
        .ok_or_else(|| ApiError::bad_request("Missing stripe-signature header"))?;

    if let Some(billing_service) = &state.services.billing_service {
        billing_service.handle_webhook(&body, signature).await?;
        Ok(Json(ApiResponse::success(())))
    } else {
        Err(ApiError::bad_request(
            "Billing is not enabled on this server",
        ))
    }
}

/// Create a billing portal session
#[utoipa::path(
    post,
    path = "/portal",
    tags = ["billing", "internal"],
    request_body = String,
    responses(
        (status = 200, description = "Portal session URL", body = ApiResponse<String>),
        (status = 400, description = "Billing not enabled", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_portal_session(
    State(state): State<Arc<AppState>>,
    RequireOwner(_user): RequireOwner,
    user: AuthenticatedUser,
    Json(return_url): Json<String>,
) -> ApiResult<Json<ApiResponse<String>>> {
    if let Some(billing_service) = &state.services.billing_service {
        let session_url = billing_service
            .create_portal_session(user.organization_id, return_url)
            .await?;

        Ok(Json(ApiResponse::success(session_url)))
    } else {
        Err(ApiError::bad_request("Billing not enabled"))
    }
}
