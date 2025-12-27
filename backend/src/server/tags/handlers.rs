use crate::server::auth::middleware::permissions::RequireAdmin;
use crate::server::shared::handlers::traits::create_handler;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse};
use crate::server::tags::r#impl::base::Tag;
use crate::server::{
    config::AppState,
    shared::types::api::{ApiResponse, ApiResult},
};
use axum::{extract::State, response::Json};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for most CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Tag, "tags", "tag");
    crate::crud_update_handler!(Tag, "tags", "tag");
    crate::crud_delete_handler!(Tag, "tags", "tag");
    crate::crud_bulk_delete_handler!(Tag, "tags");
    crate::crud_get_all_handler!(Tag, "tags", "tag");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_tag))
        .routes(routes!(
            generated::get_by_id,
            generated::update,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new tag
#[utoipa::path(
    post,
    path = "",
    tag = "tags",
    request_body = Tag,
    responses(
        (status = 200, description = "Tag created successfully", body = ApiResponse<Tag>),
        (status = 409, description = "Tag name already exists", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn create_tag(
    state: State<Arc<AppState>>,
    RequireAdmin(user): RequireAdmin,
    Json(tag): Json<Tag>,
) -> ApiResult<Json<ApiResponse<Tag>>> {
    let name_filter = EntityFilter::unfiltered()
        .organization_id(&user.organization_id)
        .name(tag.base.name.clone());

    if let Some(existing_with_name) = state.services.tag_service.get_one(name_filter).await? {
        return Err(ApiError::conflict(&format!(
            "Tag names must be unique; a tag named \"{}\" already exists",
            existing_with_name.base.name
        )));
    }

    create_handler::<Tag>(state, RequireAdmin(user).into(), Json(tag)).await
}
