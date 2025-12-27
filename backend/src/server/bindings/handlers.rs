use axum::Json;
use axum::extract::{Path, State};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::bindings::r#impl::base::{Binding, BindingType};
use crate::server::bindings::service::BindingService;
use crate::server::config::AppState;
use crate::server::shared::handlers::query::BindingQuery;
use crate::server::shared::handlers::traits::{CrudHandlers, create_handler, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult};

impl CrudHandlers for Binding {
    type Service = BindingService;
    type FilterQuery = BindingQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.binding_service
    }
}

mod generated {
    use super::*;
    crate::crud_get_all_handler!(Binding, "bindings", "binding");
    crate::crud_get_by_id_handler!(Binding, "bindings", "binding");
    crate::crud_delete_handler!(Binding, "bindings", "binding");
    crate::crud_bulk_delete_handler!(Binding, "bindings");
}

/// Validates that a binding doesn't conflict with existing bindings.
/// Rules:
/// - Interface binding conflicts with port bindings on same interface OR port bindings on all interfaces
/// - Port binding (specific interface) conflicts with interface binding on same interface
/// - Port binding (all interfaces) conflicts with ANY interface binding for this service
async fn validate_no_binding_type_conflict(
    state: &AppState,
    binding: &Binding,
    exclude_id: Option<Uuid>,
) -> Result<(), ApiError> {
    let service_id = binding.service_id();

    match binding.base.binding_type {
        BindingType::Interface { interface_id } => {
            // Check for conflicting port bindings: same interface OR all-interfaces
            let filter = EntityFilter::unfiltered().service_id(&service_id);
            let existing = state.services.binding_service.get_all(filter).await?;

            for existing_binding in existing {
                if exclude_id == Some(existing_binding.id) {
                    continue;
                }

                // Conflict if port binding is on same interface OR on all interfaces
                if let BindingType::Port {
                    interface_id: existing_iface,
                    ..
                } = existing_binding.base.binding_type
                    && (existing_iface == Some(interface_id) || existing_iface.is_none())
                {
                    return Err(ApiError::conflict(
                        "Cannot add interface binding: service already has a port binding on this interface \
                             (or on all interfaces).",
                    ));
                }
            }
        }
        BindingType::Port {
            interface_id: Some(interface_id),
            ..
        } => {
            // Check for conflicting interface binding on same interface
            let filter = EntityFilter::unfiltered().service_id(&service_id);
            let existing = state.services.binding_service.get_all(filter).await?;

            for existing_binding in existing {
                if exclude_id == Some(existing_binding.id) {
                    continue;
                }

                if let BindingType::Interface {
                    interface_id: existing_iface,
                } = existing_binding.base.binding_type
                    && existing_iface == interface_id
                {
                    return Err(ApiError::conflict(
                        "Cannot add port binding: service already has an interface binding on this interface.",
                    ));
                }
            }
        }
        BindingType::Port {
            interface_id: None, ..
        } => {
            // Port binding on all interfaces: conflicts with ANY interface binding
            let filter = EntityFilter::unfiltered().service_id(&service_id);
            let existing = state.services.binding_service.get_all(filter).await?;

            for existing_binding in existing {
                if exclude_id == Some(existing_binding.id) {
                    continue;
                }

                if matches!(
                    existing_binding.base.binding_type,
                    BindingType::Interface { .. }
                ) {
                    return Err(ApiError::conflict(
                        "Cannot add port binding on all interfaces: service already has interface bindings.",
                    ));
                }
            }
        }
    }

    Ok(())
}

/// Create a new binding
///
/// Creates a binding that associates a service with a port or interface.
///
/// ### Binding Types
///
/// - **Interface binding**: Service is present at an interface (IP address) without a specific port.
///   Used for non-port-bound services like gateways.
/// - **Port binding (specific interface)**: Service listens on a specific port on a specific interface.
/// - **Port binding (all interfaces)**: Service listens on a specific port on all interfaces
///   (`interface_id: null`).
///
/// ### Validation and Deduplication Rules
///
/// - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
///   A port binding on all interfaces conflicts with any interface binding for the same service.
/// - **All-interfaces precedence**: When creating a port binding with `interface_id: null`,
///   any existing specific-interface bindings for the same port are automatically removed,
///   as they are superseded by the all-interfaces binding.
#[utoipa::path(
    post,
    path = "",
    tag = "bindings",
    request_body = Binding,
    responses(
        (status = 200, description = "Binding created (superseded bindings may be removed)", body = ApiResponse<Binding>),
        (status = 400, description = "Referenced port or interface does not exist", body = ApiErrorResponse),
        (status = 409, description = "Conflict with existing binding type", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_binding(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(binding): Json<Binding>,
) -> ApiResult<Json<ApiResponse<Binding>>> {
    validate_no_binding_type_conflict(&state, &binding, None).await?;

    // If creating an all-interfaces port binding, remove any specific-interface bindings for the same port
    // (the all-interfaces binding supersedes them)
    if let BindingType::Port {
        port_id,
        interface_id: None,
    } = &binding.base.binding_type
    {
        let service_id = binding.service_id();
        let filter = EntityFilter::unfiltered().service_id(&service_id);
        let existing = state.services.binding_service.get_all(filter).await?;

        for existing_binding in existing {
            if let BindingType::Port {
                port_id: existing_port_id,
                interface_id: Some(_),
            } = &existing_binding.base.binding_type
                && existing_port_id == port_id
            {
                // Delete the specific-interface binding that's being superseded
                tracing::info!(
                    binding_id = %existing_binding.id,
                    port_id = %existing_port_id,
                    "Removing specific-interface binding superseded by all-interfaces binding"
                );
                state
                    .services
                    .binding_service
                    .delete(&existing_binding.id, user.0.clone().into())
                    .await?;
            }
        }
    }

    create_handler::<Binding>(State(state), user, Json(binding)).await
}

/// Update a binding
///
/// Updates an existing binding. The same conflict detection rules from binding creation apply.
///
/// ## Validation Rules
///
/// - **Conflict detection**: The updated binding must not conflict with other bindings on the
///   same service. Interface bindings conflict with port bindings on the same interface.
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "bindings",
    params(("id" = Uuid, Path, description = "Binding ID")),
    request_body = Binding,
    responses(
        (status = 200, description = "Binding updated", body = ApiResponse<Binding>),
        (status = 400, description = "Referenced port or interface does not exist", body = ApiErrorResponse),
        (status = 409, description = "Conflict with existing binding type", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_binding(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    Json(binding): Json<Binding>,
) -> ApiResult<Json<ApiResponse<Binding>>> {
    validate_no_binding_type_conflict(&state, &binding, Some(*path)).await?;
    update_handler::<Binding>(State(state), user, path, Json(binding)).await
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_binding))
        .routes(routes!(
            generated::get_by_id,
            update_binding,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}
