use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::features::{BlockedInDemoMode, RequireFeature};
use crate::server::auth::middleware::permissions::{RequireAdmin, RequireMember};
use crate::server::shared::handlers::traits::{BulkDeleteResponse, CrudHandlers, delete_handler};
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
use axum::response::Json;
use axum::{extract::State, routing::put};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(User, "users", "user");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_users))
        .routes(routes!(generated::get_by_id, delete_user))
        .routes(routes!(bulk_delete_users))
        // Self-update and admin endpoints not in OpenAPI spec
        .route("/{id}", put(update_user))
        .route("/{id}/admin", put(admin_update_user))
}

/// List all users
/// 
/// Returns a list of users with permissions below the permissions of the user making the request.
#[utoipa::path(
    get,
    path = "",
    tag = "users",
    responses(
        (status = 200, description = "List of users", body = Vec<User>),
    ),
    security(("session" = []))
)]
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
        .filter(|u| {
            user.permissions == UserOrgPermissions::Owner
                || u.base.permissions < user.permissions
                || u.id == user.user_id
        })
        .cloned()
        .collect();

    Ok(Json(ApiResponse::success(users)))
}

/// Delete a user
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "users",
    params(("id" = Uuid, Path, description = "User ID")),
    responses(
        (status = 200, description = "User deleted"),
        (status = 404, description = "User not found"),
        (status = 403, description = "Cannot delete user with higher permissions"),
        (status = 409, description = "Cannot delete the only owner"),
    ),
    security(("session" = []))
)]
pub async fn delete_user(
    state: State<Arc<AppState>>,
    require_admin: RequireAdmin,
    _demo_check: RequireFeature<BlockedInDemoMode>,
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

/// Update your own user record
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "users",
    params(("id" = Uuid, Path, description = "User ID")),
    request_body = User,
    responses(
        (status = 200, description = "User updated", body = User),
        (status = 403, description = "Cannot update another user's record"),
        (status = 404, description = "User not found"),
    ),
    security(("session" = []))
)]
pub async fn update_user(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    _demo_check: RequireFeature<BlockedInDemoMode>,
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

    // Preserve fields that shouldn't be changed via this endpoint
    request.base.email = existing.base.email.clone();
    request.base.password_hash = existing.base.password_hash.clone();
    request.base.oidc_provider = existing.base.oidc_provider.clone();
    request.base.oidc_subject = existing.base.oidc_subject.clone();
    request.base.oidc_linked_at = existing.base.oidc_linked_at;

    let updated = service
        .update(&mut request, user.into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}

/// Admin update user (for changing permissions)
async fn admin_update_user(
    State(state): State<Arc<AppState>>,
    RequireAdmin(admin): RequireAdmin,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Path(id): Path<Uuid>,
    Json(mut request): Json<User>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let service = User::get_service(&state);

    // Verify target user exists
    let existing = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("User '{}' not found", id)))?;

    // Cannot edit yourself through this endpoint
    if admin.user_id == id {
        return Err(ApiError::forbidden(
            "Use the regular update endpoint to edit your own user",
        ));
    }

    // Can only edit users with lower permissions than yourself
    if existing.base.permissions >= admin.permissions {
        return Err(ApiError::forbidden(
            "You can only edit users with lower permissions than you",
        ));
    }

    // Cannot promote user to same or higher level than yourself
    if admin.permissions != UserOrgPermissions::Owner
        && request.base.permissions >= admin.permissions
    {
        return Err(ApiError::forbidden(
            "You cannot promote a user to your permission level or higher",
        ));
    }

    // Cannot change organization
    if request.base.organization_id != existing.base.organization_id {
        return Err(ApiError::forbidden(
            "You cannot change a user's organization",
        ));
    }

    // Preserve fields that shouldn't be changed via this endpoint
    request.base.email = existing.base.email.clone();
    request.base.password_hash = existing.base.password_hash.clone();
    request.base.oidc_provider = existing.base.oidc_provider.clone();
    request.base.oidc_subject = existing.base.oidc_subject.clone();
    request.base.oidc_linked_at = existing.base.oidc_linked_at;

    let updated = service
        .update(&mut request, admin.into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}

/// Bulk delete users
#[utoipa::path(
    post,
    path = "/bulk-delete",
    tag = "users",
    request_body(content = Vec<Uuid>, description = "Array of user IDs to delete"),
    responses(
        (status = 200, description = "Users deleted successfully", body = BulkDeleteResponse),
        (status = 403, description = "Cannot delete users with higher permissions"),
    ),
    security(("session" = []))
)]
pub async fn bulk_delete_users(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Json(ids): Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    use crate::server::shared::handlers::traits::bulk_delete_handler;

    let user_filter = EntityFilter::unfiltered().entity_ids(&ids);
    let users = state.services.user_service.get_all(user_filter).await?;

    if users.iter().any(|u| u.base.permissions > user.permissions) {
        return Err(ApiError::unauthorized(
            "You can only delete users with lower permissions than you".to_string(),
        ));
    }

    let owners = state
        .services
        .user_service
        .get_organization_owners(&user.organization_id)
        .await?;

    if owners.iter().all(|o| users.contains(o)) {
        return Err(ApiError::unauthorized(
            "Can't delete all of an organization's owners".to_string(),
        ));
    }

    bulk_delete_handler::<User>(
        axum::extract::State(state),
        RequireMember(user),
        axum::extract::Json(ids),
    )
    .await
}
