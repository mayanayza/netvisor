use axum::Json;
use axum::extract::{Path, State};
use uuid::Uuid;

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::shared::handlers::traits::{create_handler, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for most CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Interface, "interfaces", "interface");
    crate::crud_get_all_handler!(Interface, "interfaces", "interface");
    crate::crud_delete_handler!(Interface, "interfaces", "interface");
    crate::crud_bulk_delete_handler!(Interface, "interfaces");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_interface))
        .routes(routes!(
            generated::get_by_id,
            update_interface,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Validate that interface's host and subnet are on the same network as the interface,
/// and that the IP address falls within the subnet's CIDR range.
async fn validate_interface_consistency(
    state: &AppState,
    interface: &Interface,
) -> Result<(), ApiError> {
    // Validate host is on the same network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&interface.base.host_id)
        .await?
        && host.base.network_id != interface.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, interface can't be on a different network ({})",
            host.base.network_id, interface.base.network_id
        )));
    }

    // Validate subnet is on the same network AND IP is within CIDR
    if let Some(subnet) = state
        .services
        .subnet_service
        .get_by_id(&interface.base.subnet_id)
        .await?
    {
        if subnet.base.network_id != interface.base.network_id {
            return Err(ApiError::bad_request(&format!(
                "Subnet \"{}\" is on network {}, interface can't be on a different network ({})",
                subnet.base.name, subnet.base.network_id, interface.base.network_id
            )));
        }

        // Validate IP address is within subnet CIDR
        if !subnet.base.cidr.contains(&interface.base.ip_address) {
            return Err(ApiError::bad_request(&format!(
                "IP address {} is not within subnet \"{}\" CIDR range ({})",
                interface.base.ip_address, subnet.base.name, subnet.base.cidr
            )));
        }
    }

    Ok(())
}

/// Create a new interface
#[utoipa::path(
    post,
    path = "",
    tag = "interfaces",
    request_body = Interface,
    responses(
        (status = 200, description = "Interface created successfully", body = ApiResponse<Interface>),
        (status = 400, description = "Network mismatch or invalid request", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_interface(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(interface): Json<Interface>,
) -> ApiResult<Json<ApiResponse<Interface>>> {
    validate_interface_consistency(&state, &interface).await?;
    create_handler::<Interface>(State(state), user, Json(interface)).await
}

/// Update an interface
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "interfaces",
    params(("id" = Uuid, Path, description = "Interface ID")),
    request_body = Interface,
    responses(
        (status = 200, description = "Interface updated successfully", body = ApiResponse<Interface>),
        (status = 400, description = "Network mismatch or invalid request", body = ApiErrorResponse),
        (status = 404, description = "Interface not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_interface(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    Json(interface): Json<Interface>,
) -> ApiResult<Json<ApiResponse<Interface>>> {
    validate_interface_consistency(&state, &interface).await?;
    update_handler::<Interface>(State(state), user, path, Json(interface)).await
}
