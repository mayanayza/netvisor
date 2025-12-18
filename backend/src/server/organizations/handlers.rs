use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember};
use crate::server::config::AppState;
use crate::server::organizations::r#impl::base::Organization;
use crate::server::shared::handlers::traits::{CrudHandlers, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::ApiError;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::ApiResult;
use anyhow::anyhow;
use axum::Json;
use axum::Router;
use axum::extract::Path;
use axum::extract::State;
use axum::routing::{get, put};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/{id}", put(update_org_name))
        .route("/", get(get_by_id_handler))
}

pub async fn update_org_name(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    Path(id): Path<Uuid>,
    Json(mut org): Json<Organization>,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    if id != org.id {
        return Err(ApiError::bad_request("Org ID must match path ID"));
    }

    let current_org = state
        .services
        .organization_service
        .get_by_id(&org.id)
        .await?
        .ok_or_else(|| anyhow!("Could not find org"))?;

    org.base.onboarding = current_org.base.onboarding;
    org.base.plan = current_org.base.plan;
    org.base.stripe_customer_id = current_org.base.stripe_customer_id;
    org.base.plan_status = current_org.base.plan_status;

    update_handler::<Organization>(
        axum::extract::State(state),
        RequireMember(user),
        axum::extract::Path(id),
        axum::extract::Json(org),
    )
    .await
}

pub async fn get_by_id_handler(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    let service = Organization::get_service(&state);
    let entity = service
        .get_by_id(&user.organization_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| {
            ApiError::not_found(format!("Organization '{}' not found", user.organization_id))
        })?;

    Ok(Json(ApiResponse::success(entity)))
}
