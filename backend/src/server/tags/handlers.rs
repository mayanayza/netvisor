use crate::server::auth::middleware::permissions::RequireAdmin;
use crate::server::shared::handlers::traits::{
    create_handler,
};
use crate::server::shared::types::api::ApiError;
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
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new tag
#[utoipa::path(
    post,
    path = "",
    tag = "tags",
    request_body = Tag,
    responses(
        (status = 200, description = "Tag created successfully", body = Tag),
        (status = 409, description = "Tag name already exists"),
    ),
    security(("session" = []))
)]
pub async fn create_tag(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    json: Json<Tag>,
) -> ApiResult<Json<ApiResponse<Tag>>> {
    let created = create_handler::<Tag>(state, admin.into(), json.clone()).await;

    match created {
        Ok(c) => Ok(c),
        Err(e)
            if e.message
                .contains("violates unique constraint \"idx_tags_org_name\"") =>
        {
            Err(ApiError::conflict(&format!(
                "Tag names must be unique; a tag named \"{}\" already exists",
                json.base.name
            )))
        }
        Err(e) => Err(e),
    }
}