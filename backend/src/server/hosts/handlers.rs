use crate::server::auth::middleware::auth::AuthenticatedDaemon;
use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, bulk_delete_handler, delete_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::validation::{validate_network_access, validate_read_access};
use crate::server::{
    config::AppState,
    hosts::r#impl::{
        api::{CreateHostRequest, DiscoveryHostRequest, HostResponse, UpdateHostRequest},
        base::Host,
    },
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::extract::{Path, State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_hosts, create_host))
        .routes(routes!(get_host_by_id, update_host, delete_host))
        .routes(routes!(bulk_delete_hosts))
        .routes(routes!(create_host_discovery))
        .routes(routes!(consolidate_hosts))
}

/// List all hosts
///
/// Returns all hosts the authenticated user has access to, with their
/// interfaces, ports, and services included.
#[utoipa::path(
    get,
    path = "",
    tag = "hosts",
    responses(
        (status = 200, description = "List of hosts with their children", body = Vec<HostResponse>),
    ),
    security(("session" = []))
)]
async fn get_all_hosts(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { network_ids, .. }: MemberOrDaemon,
) -> ApiResult<Json<ApiResponse<Vec<HostResponse>>>> {
    let filter = EntityFilter::unfiltered().network_ids(&network_ids);
    let hosts = state
        .services
        .host_service
        .get_all_host_responses(filter)
        .await?;
    Ok(Json(ApiResponse::success(hosts)))
}

/// Get a host by ID
///
/// Returns a single host with its interfaces, ports, and services.
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "hosts",
    params(("id" = Uuid, Path, description = "Host ID")),
    responses(
        (status = 200, description = "Host found", body = HostResponse),
        (status = 404, description = "Host not found"),
    ),
    security(("session" = []))
)]
async fn get_host_by_id(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { network_ids, .. }: MemberOrDaemon,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host = state
        .services
        .host_service
        .get_host_response(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Host {} not found", id)))?;

    // Verify network access
    if !network_ids.contains(&host.network_id) {
        return Err(ApiError::not_found(format!("Host {} not found", id)));
    }

    Ok(Json(ApiResponse::success(host)))
}

/// Create a new host
///
/// Creates a host with optional interfaces, ports, and services.
/// The `source` field is automatically set to `Manual`.
/// IDs for the host and all children are generated server-side.
#[utoipa::path(
    post,
    path = "",
    tag = "hosts",
    request_body = CreateHostRequest,
    responses(
        (status = 200, description = "Host created successfully", body = HostResponse),
        (status = 400, description = "Invalid request - network not found or subnet mismatch"),
    ),
    security(("session" = []))
)]
async fn create_host(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon {
        entity,
        network_ids,
        ..
    }: MemberOrDaemon,
    Json(request): Json<CreateHostRequest>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host_service = &state.services.host_service;

    // Validate user has access to the network
    validate_network_access(Some(request.network_id), &network_ids, "create")?;

    // Validate network_id exists
    let _network = state
        .services
        .network_service
        .get_by_id(&request.network_id)
        .await?
        .ok_or_else(|| {
            ApiError::bad_request(&format!("Network {} not found", request.network_id))
        })?;

    // Check interface subnets are on the same network
    for interface in &request.interfaces {
        if let Some(subnet) = state
            .services
            .subnet_service
            .get_by_id(&interface.subnet_id)
            .await?
            && subnet.base.network_id != request.network_id
        {
            return Err(ApiError::bad_request(&format!(
                "Host is on network {}, cannot have an interface with a subnet \"{}\" which is on network {}.",
                request.network_id, subnet.base.name, subnet.base.network_id
            )));
        }
    }

    let host_response = host_service.create_from_request(request, entity).await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Update a host
///
/// Updates host properties. Children (interfaces, ports, services)
/// are managed via their own endpoints.
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "hosts",
    params(("id" = Uuid, Path, description = "Host ID")),
    request_body = UpdateHostRequest,
    responses(
        (status = 200, description = "Host updated", body = HostResponse),
        (status = 404, description = "Host not found"),
    ),
    security(("session" = []))
)]
async fn update_host(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(request): Json<UpdateHostRequest>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host_service = &state.services.host_service;

    // Fetch existing host to validate network access
    let existing_host = host_service
        .get_by_id(&request.id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Host {} not found", request.id)))?;

    validate_read_access(
        Some(existing_host.base.network_id),
        None,
        &user.network_ids,
        user.organization_id,
    )?;

    let host_response = host_service
        .update_from_request(request, user.into())
        .await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Internal endpoint for daemon discovery
///
/// Used by daemons to report discovered hosts. Accepts full entities with
/// pre-generated IDs. Uses upsert behavior to merge with existing hosts.
#[utoipa::path(
    post,
    path = "/discovery",
    tag = "hosts",
    request_body = DiscoveryHostRequest,
    responses(
        (status = 200, description = "Host discovered/updated", body = HostResponse),
    ),
    security(("api_key" = []))
)]
async fn create_host_discovery(
    State(state): State<Arc<AppState>>,
    daemon: AuthenticatedDaemon,
    Json(request): Json<DiscoveryHostRequest>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host_service = &state.services.host_service;

    let DiscoveryHostRequest {
        host,
        interfaces,
        ports,
        services,
    } = request;

    let host_response = host_service
        .discover_host(host, interfaces, ports, services, daemon.into())
        .await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Consolidate two hosts into one
///
/// Merges all interfaces, ports, and services from `other_host` into
/// `destination_host`, then deletes `other_host`. Both hosts must be
/// on the same network.
#[utoipa::path(
    put,
    path = "/{destination_host}/consolidate/{other_host}",
    tag = "hosts",
    params(
        ("destination_host" = Uuid, Path, description = "Destination host ID - will receive all children"),
        ("other_host" = Uuid, Path, description = "Host to merge into destination - will be deleted")
    ),
    responses(
        (status = 200, description = "Hosts consolidated successfully", body = HostResponse),
        (status = 404, description = "One or both hosts not found"),
        (status = 400, description = "Hosts are on different networks"),
    ),
    security(("session" = []))
)]
async fn consolidate_hosts(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path((destination_host_id, other_host_id)): Path<(Uuid, Uuid)>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host_service = &state.services.host_service;

    let destination_host = host_service
        .get_by_id(&destination_host_id)
        .await?
        .ok_or_else(|| {
            ApiError::not_found(format!(
                "Could not find destination host {}",
                destination_host_id
            ))
        })?;
    let other_host = host_service
        .get_by_id(&other_host_id)
        .await?
        .ok_or_else(|| {
            ApiError::not_found(format!(
                "Could not find host to consolidate {}",
                other_host_id
            ))
        })?;

    // Validate user has access to both hosts
    validate_read_access(
        Some(destination_host.base.network_id),
        None,
        &user.network_ids,
        user.organization_id,
    )?;
    validate_read_access(
        Some(other_host.base.network_id),
        None,
        &user.network_ids,
        user.organization_id,
    )?;

    // Make sure hosts are on same network
    if destination_host.base.network_id != other_host.base.network_id {
        return Err(ApiError::bad_request(&format!(
            "Destination Host is on network {}, other host \"{}\" can't be on a different network ({}).",
            destination_host.base.network_id, other_host.base.name, other_host.base.network_id
        )));
    }

    let host_response = host_service
        .consolidate_hosts(destination_host, other_host, user.into())
        .await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Delete a host, checking for associated daemons first
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "hosts",
    params(
        ("id" = Uuid, Path, description = "Host ID")
    ),
    responses(
        (status = 200, description = "Host deleted"),
        (status = 404, description = "Host not found"),
        (status = 409, description = "Host has associated daemon"),
    ),
    security(("session" = []))
)]
pub async fn delete_host(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Pre-validation: Can't delete a host with an associated daemon
    let host_filter = EntityFilter::unfiltered().host_id(&id);
    if state
        .services
        .daemon_service
        .get_one(host_filter)
        .await?
        .is_some()
    {
        return Err(ApiError::conflict(
            "Can't delete a host with an associated daemon. Delete the daemon first.",
        ));
    }

    // Delegate to generic handler (handles auth checks, deletion)
    delete_handler::<Host>(State(state), user, Path(id)).await
}

/// Bulk delete hosts
///
/// Deletes multiple hosts in a single request. The request body should be
/// an array of host IDs to delete. Fails if any host has an associated daemon.
#[utoipa::path(
    post,
    path = "/bulk-delete",
    tag = "hosts",
    request_body(content = Vec<Uuid>, description = "Array of host IDs to delete"),
    responses(
        (status = 200, description = "Hosts deleted successfully", body = BulkDeleteResponse),
        (status = 409, description = "One or more hosts has an associated daemon - delete daemons first"),
    ),
    security(("session" = []))
)]
pub async fn bulk_delete_hosts(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(ids): Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    let daemon_service = &state.services.daemon_service;

    let host_filter = EntityFilter::unfiltered().host_ids(&ids);

    if !daemon_service.get_all(host_filter).await?.is_empty() {
        return Err(ApiError::conflict(
            "One or more hosts has an associated daemon, and can't be deleted. Delete the daemon(s) first.",
        ));
    }

    bulk_delete_handler::<Host>(
        axum::extract::State(state),
        RequireMember(user),
        axum::extract::Json(ids),
    )
    .await
}
