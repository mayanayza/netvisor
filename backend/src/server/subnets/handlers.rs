use crate::server::auth::middleware::auth::{AuthenticatedEntity, AuthenticatedUser};
use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::traits::{CrudHandlers, create_handler};
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        types::api::{ApiResponse, ApiResult},
    },
    subnets::r#impl::base::Subnet,
};
use axum::extract::{State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for most CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Subnet, "subnets", "subnet");
    crate::crud_get_all_handler!(Subnet, "subnets", "subnet");
    crate::crud_update_handler!(Subnet, "subnets", "subnet");
    crate::crud_delete_handler!(Subnet, "subnets", "subnet");
    crate::crud_bulk_delete_handler!(Subnet, "subnets");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_subnet))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new subnet
#[utoipa::path(
    post,
    path = "",
    tag = "subnets",
    request_body = Subnet,
    responses(
        (status = 200, description = "Subnet created successfully", body = Subnet),
        (status = 400, description = "Invalid request"),
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
        AuthenticatedEntity::User{user_id, organization_id,permissions,network_ids, email} => {
            let authenticated_user = AuthenticatedUser{user_id, organization_id,permissions,network_ids, email};
            create_handler::<Subnet>(state, RequireMember(authenticated_user), Json(request)).await?
        },
        AuthenticatedEntity::Daemon{network_id, .. } => {
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
                return Err(ApiError::bad_request(&format!("Daemon tried to create subnet on a network that it doesn't belong to: {}", entity.to_string())));    
            }
        },
        _ => {
            return Err(ApiError::bad_request(&format!("AuthenticatedEntity besides a user or daemon tried to create a subnet: {}", entity.to_string())));
        }
    };

    Ok(created)
}
