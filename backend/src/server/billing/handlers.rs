use crate::server::auth::middleware::AuthenticatedUser;
use crate::server::billing::types::api::{CreateCheckoutRequest};
use crate::server::billing::types::base::BillingPlan;
use axum::routing::{get, post};
use axum::Router;
use axum::extract::State;
use crate::server::config::AppState;
use crate::server::shared::types::api::{ApiError, ApiResult};
use axum::Json;
use crate::server::shared::types::api::ApiResponse;
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/plans", get(get_billing_plans))
        .route("/checkout", post(create_checkout_session))
}

async fn get_billing_plans(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<BillingPlan>>>> {
    
    if let Some(billing_service) = state.services.billing_service.clone() {
        let plans = billing_service.get_plans();
        tracing::info!("{:?}", plans);
        return Ok(Json(ApiResponse::success(plans)));
    } else {
        return Err(ApiError::bad_request("Billing is not enabled on this server"));
    }
}


async fn create_checkout_session(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    Json(request): Json<CreateCheckoutRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {

    // Build success/cancel URLs
    let success_url = format!("{}/billing/success", request.url);
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
        )
        .await?;
    
        Ok(Json(ApiResponse::success(
            session.url.unwrap()
        )))
    } else {
        return Err(ApiError::bad_request("Billing is not enabled on this server"));
    }    
}
