use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::shared::handlers::traits::update_handler;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult};
use crate::server::shared::types::entities::EntitySource;
use crate::server::shared::validation::validate_network_access;
use crate::server::{
    config::AppState,
    services::r#impl::{api::CreateServiceRequest, base::Service},
};
use axum::Json;
use axum::extract::{Path, State};
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
        .routes(routes!(
            generated::get_by_id,
            update_service,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new service
///
/// Creates a service with optional bindings to interfaces or ports.
/// The `id`, `created_at`, `updated_at`, and `source` fields are generated server-side.
/// Bindings are specified without `service_id` or `network_id` - these are assigned automatically.
///
/// ### Binding Validation Rules
///
/// - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
///   service's host. Bindings referencing entities from other hosts will be rejected.
/// - **Deduplication**: Duplicate bindings in the same request are automatically deduplicated.
/// - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
///   is included, any specific-interface bindings for the same port are automatically removed.
/// - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
///   A port binding on all interfaces conflicts with any interface binding.
#[utoipa::path(
    post,
    path = "",
    tag = "services",
    request_body = CreateServiceRequest,
    responses(
        (status = 200, description = "Service created successfully", body = ApiResponse<Service>),
        (status = 400, description = "Validation error: host network mismatch, cross-host binding, or binding conflict", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn create_service(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(request): Json<CreateServiceRequest>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Validate user has access to the network
    validate_network_access(Some(request.network_id()), &user.network_ids, "create")?;

    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&request.host_id())
        .await?
        && host.base.network_id != request.network_id()
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service can't be on a different network ({}).",
            host.base.network_id,
            request.network_id()
        )));
    }

    // Convert request to Service entity
    let service = request.into_service(EntitySource::Manual);

    // Create the service
    let created = state
        .services
        .service_service
        .create(service, user.into())
        .await?;

    Ok(Json(ApiResponse::success(created)))
}

/// Update a service
///
/// Updates an existing service. All binding validation rules from service creation apply here as well.
///
/// ## Binding Validation Rules
///
/// - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
///   service's host. Bindings referencing entities from other hosts will be rejected.
/// - **Deduplication**: Duplicate bindings are automatically deduplicated.
/// - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
///   is included, any specific-interface bindings for the same port are automatically removed.
/// - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "services",
    params(("id" = Uuid, Path, description = "Service ID")),
    request_body = Service,
    responses(
        (status = 200, description = "Service updated", body = ApiResponse<Service>),
        (status = 400, description = "Validation error: host network mismatch, cross-host binding, or binding conflict", body = ApiErrorResponse),
        (status = 404, description = "Service not found", body = ApiErrorResponse),
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
