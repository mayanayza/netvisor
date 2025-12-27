use crate::server::auth::middleware::auth::{AuthenticatedEntity, AuthenticatedUser};
use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::traits::{CrudHandlers, create_handler, update_handler};
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse};
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        types::api::{ApiResponse, ApiResult},
    },
    subnets::r#impl::base::Subnet,
};
use axum::extract::{Path, State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// Generated handlers for most CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Subnet, "subnets", "subnet");
    crate::crud_get_all_handler!(Subnet, "subnets", "subnet");
    crate::crud_delete_handler!(Subnet, "subnets", "subnet");
    crate::crud_bulk_delete_handler!(Subnet, "subnets");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_subnet))
        .routes(routes!(
            generated::get_by_id,
            update_subnet,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new subnet
#[utoipa::path(
    post,
    path = "",
    tag = "subnets",
    request_body = Subnet,
    responses(
        (status = 200, description = "Subnet created successfully", body = ApiResponse<Subnet>),
        (status = 400, description = "Invalid request", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_subnet(
    state: State<Arc<AppState>>,
    MemberOrDaemon { entity, .. }: MemberOrDaemon,
    Json(request): Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    tracing::debug!(
        subnet_name = %request.base.name,
        subnet_cidr = %request.base.cidr,
        network_id = %request.base.network_id,
        entity_id = %entity.entity_id(),
        "Subnet create request received"
    );

    if let Err(err) = request.validate() {
        tracing::warn!(
            subnet_name = %request.base.name,
            subnet_cidr = %request.base.cidr,
            entity_id = %entity.entity_id(),
            error = %err,
            "Subnet validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "Subnet validation failed: {}",
            err
        )));
    }

    let created = match entity {
        AuthenticatedEntity::User {
            user_id,
            organization_id,
            permissions,
            network_ids,
            email,
        } => {
            let authenticated_user = AuthenticatedUser {
                user_id,
                organization_id,
                permissions,
                network_ids,
                email,
            };
            create_handler::<Subnet>(state, RequireMember(authenticated_user), Json(request))
                .await?
        }
        AuthenticatedEntity::Daemon { network_id, .. } => {
            if network_id == request.base.network_id {
                let service = Subnet::get_service(&state);
                let created = service.create(request, entity.clone()).await.map_err(|e| {
                    tracing::error!(
                        error = %e,
                        entity_id = %entity.entity_id(),
                        "Failed to create subnet"
                    );
                    ApiError::internal_error(&e.to_string())
                })?;

                Json(ApiResponse::success(created))
            } else {
                return Err(ApiError::bad_request(&format!(
                    "Daemon tried to create subnet on a network that it doesn't belong to: {}",
                    entity
                )));
            }
        }
        _ => {
            return Err(ApiError::bad_request(&format!(
                "AuthenticatedEntity besides a user or daemon tried to create a subnet: {}",
                entity
            )));
        }
    };

    Ok(created)
}

/// Update a subnet
///
/// Updates subnet properties. If the CIDR is being changed, validates that
/// all existing interfaces on this subnet have IPs within the new CIDR range.
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "subnets",
    params(("id" = Uuid, Path, description = "Subnet ID")),
    request_body = Subnet,
    responses(
        (status = 200, description = "Subnet updated", body = ApiResponse<Subnet>),
        (status = 400, description = "CIDR change would orphan existing interfaces", body = ApiErrorResponse),
        (status = 404, description = "Subnet not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_subnet(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
    Json(subnet): Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    // Check if CIDR is being changed
    let current = state
        .services
        .subnet_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("Subnet {} not found", id)))?;

    if current.base.cidr != subnet.base.cidr {
        // CIDR is changing - validate that all existing interfaces are within the new CIDR
        let filter = EntityFilter::unfiltered().subnet_id(&id);
        let interfaces = state
            .services
            .interface_service
            .get_all(filter)
            .await
            .map_err(|e| ApiError::internal_error(&e.to_string()))?;

        for interface in &interfaces {
            if !subnet.base.cidr.contains(&interface.base.ip_address) {
                return Err(ApiError::bad_request(&format!(
                    "Cannot change CIDR to {}: interface \"{}\" has IP {} which would be outside the new range",
                    subnet.base.cidr,
                    interface.base.name.as_deref().unwrap_or("unnamed"),
                    interface.base.ip_address
                )));
            }
        }
    }

    // Delegate to generic handler
    update_handler::<Subnet>(State(state), user, Path(id), Json(subnet)).await
}
