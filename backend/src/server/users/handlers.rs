use crate::server::auth::middleware::{AuthenticatedUser, RequireAdmin, RequireMember};
use crate::server::shared::handlers::traits::{CrudHandlers, delete_handler, get_by_id_handler};
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::ApiError;
use crate::server::users::r#impl::base::User;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        types::api::{ApiResponse, ApiResult},
    },
};
use anyhow::anyhow;
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
    id: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let user_to_be_deleted = state
        .services
        .user_service
        .get_by_id(&id.0)
        .await?
        .ok_or_else(|| anyhow!("User {} does not exist", id.0))?;

    if require_admin.0.permissions < user_to_be_deleted.base.permissions {
        return Err(ApiError::unauthorized(
            "You can only delete users with lower permissions than you".to_string(),
        ));
    }

    let count_owners = state
        .services
        .user_service
        .get_organization_owners(&require_admin.0.organization_id)
        .await?
        .len();

    if user_to_be_deleted.base.permissions == UserOrgPermissions::Owner && count_owners == 1 {
        return Err(ApiError::conflict(
            "Can't delete the only owner in an organization.",
        ));
    }

    delete_handler::<User>(state, require_admin.into(), id).await
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
    let existing = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("User '{}' not found", id)))?;

    if request.base.organization_id != existing.base.organization_id {
        return Err(ApiError::forbidden("You cannot change your organization"));
    }

    if request.base.permissions != existing.base.permissions {
        return Err(ApiError::forbidden(
            "You cannot change your own permissions",
        ));
    }

    let updated = service
        .update(&mut request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}
