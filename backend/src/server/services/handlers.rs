use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::shared::handlers::traits::{create_handler, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use crate::server::{config::AppState, services::r#impl::base::Service};
use axum::extract::{Path, State};
use axum::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_get_all_handler!(Service, "services", "service");
    crate::crud_get_by_id_handler!(Service, "services", "service");
    crate::crud_delete_handler!(Service, "services", "service");
    crate::crud_bulk_delete_handler!(Service, "services");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_service))
        .routes(routes!(generated::get_by_id, update_service, generated::delete))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new service
#[utoipa::path(
    post,
    path = "",
    tag = "services",
    request_body = Service,
    responses(
        (status = 200, description = "Service created successfully", body = Service),
        (status = 400, description = "Host network mismatch"),
    ),
    security(("session" = []))
)]
pub async fn create_service(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&service.base.host_id)
        .await?
        && host.base.network_id != service.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service \"{}\" can't be on a different network ({}).",
            host.base.network_id, service.base.name, service.base.network_id
        )));
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Service>(State(state), user, Json(service)).await
}

/// Update a service
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "services",
    params(("id" = Uuid, Path, description = "Service ID")),
    request_body = Service,
    responses(
        (status = 200, description = "Service updated", body = Service),
        (status = 400, description = "Host network mismatch"),
        (status = 404, description = "Service not found"),
    ),
    security(("session" = []))
)]
pub async fn update_service(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&service.base.host_id)
        .await?
        && host.base.network_id != service.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service \"{}\" can't be on a different network ({}).",
            host.base.network_id, service.base.name, service.base.network_id
        )));
    }

    // Delegate to generic handler (handles validation, auth checks, update)
    update_handler::<Service>(State(state), user, Path(id), Json(service)).await
}
