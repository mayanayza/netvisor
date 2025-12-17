use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::billing::types::api::CreateCheckoutRequest;
use crate::server::config::AppState;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::{ApiError, ApiResult};
use axum::Json;
use axum::Router;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::http::header::CACHE_CONTROL;
use axum::response::IntoResponse;
use axum::routing::{get, post};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/plans", get(get_billing_plans))
        .route("/checkout", post(create_checkout_session))
        .route("/webhooks", post(handle_webhook))
        .route("/portal", post(create_portal_session))
}

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
