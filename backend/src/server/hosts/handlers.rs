use crate::server::auth::middleware::auth::{AuthenticatedDaemon, AuthenticatedEntity};
use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::query::FilterQueryExtractor;
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, delete_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiErrorResponse, EmptyApiResponse};
use crate::server::shared::validation::{
    validate_and_dedupe_tags, validate_network_access, validate_read_access,
};
use crate::server::{
    config::AppState,
    hosts::r#impl::{
        api::{CreateHostRequest, DiscoveryHostRequest, HostResponse, UpdateHostRequest},
        base::Host,
    },
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::extract::{Path, Query, State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;
use validator::Validate;

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_hosts, create_host))
        .routes(routes!(get_host_by_id, update_host, delete_host))
        .routes(routes!(bulk_delete_hosts))
        .routes(routes!(consolidate_hosts))
        .routes(routes!(create_host_discovery))
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
        (status = 200, description = "List of hosts with their children", body = ApiResponse<Vec<HostResponse>>),
    ),
    security(("session" = []))
)]
async fn get_all_hosts(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Query(query): Query<<Host as CrudHandlers>::FilterQuery>,
) -> ApiResult<Json<ApiResponse<Vec<HostResponse>>>> {
    let base_filter = EntityFilter::unfiltered().network_ids(&user.network_ids);

    let filter = query.apply_to_filter(base_filter, &user.network_ids, user.organization_id);

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
        (status = 200, description = "Host found", body = ApiResponse<HostResponse>),
        (status = 404, description = "Host not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn get_host_by_id(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    let host = state
        .services
        .host_service
        .get_host_response(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Host {} not found", id)))?;

    validate_read_access(
        Some(host.network_id),
        None,
        &user.network_ids,
        user.organization_id,
    )?;

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
        (status = 200, description = "Host created successfully", body = ApiResponse<HostResponse>),
        (status = 400, description = "Invalid request - network not found or subnet mismatch", body = ApiErrorResponse),
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
    Json(mut request): Json<CreateHostRequest>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    // Validate request (name length, etc.)
    request
        .validate()
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

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

    // Validate and dedupe tags (only for users, daemons don't use tags)
    if let AuthenticatedEntity::User {
        organization_id, ..
    } = &entity
    {
        request.tags =
            validate_and_dedupe_tags(request.tags, *organization_id, &state.services.tag_service)
                .await?;
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
        (status = 200, description = "Host updated", body = ApiResponse<HostResponse>),
        (status = 404, description = "Host not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_host(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut request): Json<UpdateHostRequest>,
) -> ApiResult<Json<ApiResponse<HostResponse>>> {
    // Validate request (name length, etc.)
    request
        .validate()
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    let host_service = &state.services.host_service;

    // Path ID is canonical - override any ID in the body
    request.id = id;

    // Fetch existing host to validate network access
    let existing_host = host_service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Host {} not found", id)))?;

    validate_read_access(
        Some(existing_host.base.network_id),
        None,
        &user.network_ids,
        user.organization_id,
    )?;

    // Validate and dedupe tags
    request.tags = validate_and_dedupe_tags(
        request.tags,
        user.organization_id,
        &state.services.tag_service,
    )
    .await?;

    let host_response = host_service
        .update_from_request(request, user.into())
        .await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Internal endpoint for daemon discovery
///
/// Used by daemons to report discovered hosts. Accepts full entities with
/// pre-generated IDs. Uses upsert behavior to merge with existing hosts.
///
/// Tagged as "internal" - included in OpenAPI spec for client generation
/// but hidden from public documentation.
#[utoipa::path(
    post,
    path = "/discovery",
    tags = ["hosts", "internal"],
    request_body = DiscoveryHostRequest,
    responses(
        (status = 200, description = "Host discovered/updated successfully", body = ApiResponse<HostResponse>),
        (status = 403, description = "Daemon cannot create hosts on other networks", body = ApiErrorResponse),
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

    if host.base.network_id != daemon.network_id {
        return Err(ApiError::forbidden(
            "Daemon cannot create hosts on networks it's not assigned to",
        ));
    }

    let host_response = host_service
        .discover_host(host, interfaces, ports, services, daemon.into())
        .await?;

    Ok(Json(ApiResponse::success(host_response)))
}

/// Consolidate hosts
///
/// Merges all interfaces, ports, and services from `other_host` into
/// `destination_host`, then deletes `other_host`. Both hosts must be
/// on the same network.
///
/// ### Merge Behavior
///
/// - **Interfaces**: Transferred to destination. If an interface with matching subnet+IP or MAC
///   already exists on destination, bindings are remapped to use the existing interface.
/// - **Ports**: Transferred to destination. If a port with the same number and protocol already
///   exists, bindings are remapped to use the existing port.
/// - **Services**: Transferred to destination with deduplication.
///   See [upsert behavior](https://scanopy.net/docs/discovery/#upsert-behavior) for details.
///
/// ### Restrictions
///
/// - Cannot consolidate a host with itself.
/// - Cannot consolidate a host that has a daemon - consolidate into it instead.
#[utoipa::path(
    put,
    path = "/{destination_host}/consolidate/{other_host}",
    tag = "hosts",
    params(
        ("destination_host" = Uuid, Path, description = "Destination host ID - will receive all children"),
        ("other_host" = Uuid, Path, description = "Host to merge into destination - will be deleted")
    ),
    responses(
        (status = 200, description = "Hosts consolidated successfully", body = ApiResponse<HostResponse>),
        (status = 404, description = "One or both hosts not found", body = ApiErrorResponse),
        (status = 400, description = "Validation error: same host, has daemon, or different networks", body = ApiErrorResponse),
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

/// Delete a host
///
/// Prevents deletion if the host has a daemon associated with it
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "hosts",
    params(
        ("id" = Uuid, Path, description = "Host ID")
    ),
    responses(
        (status = 200, description = "Host deleted", body = EmptyApiResponse),
        (status = 404, description = "Host not found", body = ApiErrorResponse),
        (status = 409, description = "Host has associated daemon", body = ApiErrorResponse),
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
        (status = 200, description = "Hosts deleted successfully", body = ApiResponse<BulkDeleteResponse>),
        (status = 409, description = "One or more hosts has an associated daemon - delete daemons first", body = ApiErrorResponse),
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
