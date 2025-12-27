use axum::Json;
use axum::extract::{Path, State};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::ports::{r#impl::base::Port, service::PortService};
use crate::server::shared::handlers::query::HostChildQuery;
use crate::server::shared::handlers::traits::{CrudHandlers, create_handler, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult};

impl CrudHandlers for Port {
    type Service = PortService;
    type FilterQuery = HostChildQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.port_service
    }
}

mod generated {
    use super::*;
    crate::crud_get_all_handler!(Port, "ports", "port");
    crate::crud_get_by_id_handler!(Port, "ports", "port");
    crate::crud_delete_handler!(Port, "ports", "port");
    crate::crud_bulk_delete_handler!(Port, "ports");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_port))
        .routes(routes!(
            generated::get_by_id,
            update_port,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Validate that port's host is on the same network as the port
async fn validate_port_network_consistency(state: &AppState, port: &Port) -> Result<(), ApiError> {
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&port.base.host_id)
        .await?
        && host.base.network_id != port.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, port can't be on a different network ({})",
            host.base.network_id, port.base.network_id
        )));
    }

    Ok(())
}

/// Create a new port
#[utoipa::path(
    post,
    path = "",
    tag = "ports",
    request_body = Port,
    responses(
        (status = 200, description = "Port created successfully", body = ApiResponse<Port>),
        (status = 400, description = "Network mismatch or duplicate port", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_port(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(port): Json<Port>,
) -> ApiResult<Json<ApiResponse<Port>>> {
    validate_port_network_consistency(&state, &port).await?;
    create_handler::<Port>(State(state), user, Json(port)).await
}

/// Update a port
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "ports",
    params(("id" = Uuid, Path, description = "Port ID")),
    request_body = Port,
    responses(
        (status = 200, description = "Port updated successfully", body = ApiResponse<Port>),
        (status = 400, description = "Network mismatch or invalid request", body = ApiErrorResponse),
        (status = 404, description = "Port not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_port(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    Json(port): Json<Port>,
) -> ApiResult<Json<ApiResponse<Port>>> {
    validate_port_network_consistency(&state, &port).await?;
    update_handler::<Port>(State(state), user, path, Json(port)).await
}
