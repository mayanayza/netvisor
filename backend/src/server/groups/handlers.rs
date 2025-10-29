use crate::server::{
    config::AppState,
    groups::types::Group,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, Query, State},
    response::Json,
    routing::{delete, get, post, put},
};
use std::{collections::HashMap, sync::Arc};
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_group))
        .route("/", get(get_all_groups))
        .route("/{id}", put(update_group))
        .route("/{id}", delete(delete_group))
}

async fn create_group(
    State(state): State<Arc<AppState>>,
    Json(request): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    let service = &state.services.group_service;

    let created_group = service.create_group(request).await?;

    Ok(Json(ApiResponse::success(created_group)))
}

async fn get_all_groups(
    State(state): State<Arc<AppState>>,
    Query(params): Query<HashMap<String, String>>,
) -> ApiResult<Json<ApiResponse<Vec<Group>>>> {
    let network_id = params
        .get("network_id")
        .and_then(|id| Uuid::parse_str(id).ok())
        .ok_or_else(|| ApiError::bad_request("network_id query parameter required"))?;

    let service = &state.services.group_service;

    let groups = service.get_all_groups(&network_id).await?;

    Ok(Json(ApiResponse::success(groups)))
}

async fn update_group(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    Json(request): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    let service = &state.services.group_service;

    let mut group = service
        .get_group(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Group '{}' not found", &id)))?;

    group.base = request.base;
    let updated_group = service.update_group(group).await?;

    Ok(Json(ApiResponse::success(updated_group)))
}

async fn delete_group(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.group_service;

    service.delete_group(&id).await?;
    Ok(Json(ApiResponse::success(())))
}
