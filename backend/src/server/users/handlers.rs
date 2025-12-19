use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::features::{BlockedInDemoMode, RequireFeature};
use crate::server::auth::middleware::permissions::{RequireAdmin, RequireMember};
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, delete_handler, get_by_id_handler,
};
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
use axum::routing::{delete, get, post, put};
use axum::{Router, extract::State, response::Json};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_users))
        .route("/{id}", put(update_user))
        .route("/{id}/admin", put(admin_update_user))
        .route("/{id}", delete(delete_user))
        .route("/{id}", get(get_by_id_handler::<User>))
        .route("/bulk-delete", post(bulk_delete_users))
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
        .filter(|u| {
            user.permissions == UserOrgPermissions::Owner
                || u.base.permissions < user.permissions
                || u.id == user.user_id
        })
        .cloned()
        .collect();

    Ok(Json(ApiResponse::success(users)))
}

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

pub async fn admin_update_user(
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

pub async fn bulk_delete_users(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Json(ids): Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
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
