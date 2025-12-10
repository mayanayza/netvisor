use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::permissions::RequireAdmin;
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, create_handler, delete_handler,
    get_by_id_handler, update_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::ApiError;
use crate::server::tags::r#impl::base::Tag;
use crate::server::{
    config::AppState,
    shared::types::api::{ApiResponse, ApiResult},
};
use axum::extract::Path;
use axum::routing::{delete, get, post, put};
use axum::{Router, extract::State, response::Json};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_tag))
        .route("/", get(get_all_tags))
        .route("/{id}", put(update_tag))
        .route("/{id}", delete(delete_tag))
        .route("/{id}", get(get_by_id_handler::<Tag>))
        .route("/bulk-delete", post(bulk_delete_tag))
}

pub async fn get_all_tags(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Tag>>>> {
    let organization_filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

    let service = Tag::get_service(&state);
    let entities = service.get_all(organization_filter).await.map_err(|e| {
        tracing::error!(
            entity_type = Tag::table_name(),
            user_id = %user.user_id,
            error = %e,
            "Failed to fetch entities"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    Ok(Json(ApiResponse::success(entities)))
}

pub async fn create_tag(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    json: Json<Tag>,
) -> ApiResult<Json<ApiResponse<Tag>>> {
    create_handler::<Tag>(state, admin.into(), json).await
}

pub async fn delete_tag(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    id: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<Tag>(state, admin.into(), id).await
}

pub async fn update_tag(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    id: Path<Uuid>,
    json: Json<Tag>,
) -> ApiResult<Json<ApiResponse<Tag>>> {
    update_handler::<Tag>(state, admin.into(), id, json).await
}

pub async fn bulk_delete_tag(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    json: Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    bulk_delete_handler::<Tag>(state, admin.into(), json).await
}
