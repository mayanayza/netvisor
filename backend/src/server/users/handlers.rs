use crate::server::auth::middleware::{AuthenticatedUser, RequireAdmin, RequireMember};
use crate::server::shared::handlers::traits::{CrudHandlers, delete_handler, get_by_id_handler};
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::ApiError;
use crate::server::users::r#impl::base::User;
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        types::api::{ApiResponse, ApiResult},
    },
};
use axum::extract::Path;
use axum::routing::{delete, get, put};
use axum::{Router, extract::State, response::Json};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_users))
        .route("/{id}", put(update_user))
        .route("/{id}", delete(delete_user))
        .route("/{id}", get(get_by_id_handler::<User>))
}

pub async fn get_all_users(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<User>>>> {
    let org_filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

    let service = User::get_service(&state);
    let users = service
        .get_all(org_filter)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .iter()
        .filter(|u| u.base.permissions < user.permissions || u.id == user.user_id)
        .cloned()
        .collect();

    Ok(Json(ApiResponse::success(users)))
}

pub async fn delete_user(
    state: State<Arc<AppState>>,
    require_admin: RequireAdmin,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<User>(state, require_admin.into(), path).await
}

pub async fn update_user(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    Path(id): Path<Uuid>,
    Json(mut request): Json<User>,
) -> ApiResult<Json<ApiResponse<User>>> {
    if user.user_id != id {
        return Err(ApiError::unauthorized(
            "You can only update your own user record".to_string(),
        ));
    }

    let service = User::get_service(&state);

    // Verify entity exists
    service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("User '{}' not found", id)))?;

    let updated = service
        .update(&mut request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}
