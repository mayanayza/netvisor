use crate::server::{
    config::AppState, hosts::types::{api::HostWithServicesRequest, base::Host}, services::types::base::Service, shared::types::api::{ApiError, ApiResponse, ApiResult}
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post, put},
};
use futures::future::try_join_all;
use itertools::{Either, Itertools};
use std::{sync::Arc};
use uuid::Uuid;
use validator::Validate;
use crate::server::auth::extractor::AuthenticatedUser;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_host))
        .route("/", get(get_all_hosts))
        .route("/", put(update_host))
        .route("/{id}", delete(delete_host))
        .route(
            "/{destination_host}/consolidate/{other_host}",
            put(consolidate_hosts),
        )
}

async fn create_host(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(request): Json<HostWithServicesRequest>,
) -> ApiResult<Json<ApiResponse<HostWithServicesRequest>>> {
    let host_service = &state.services.host_service;

    if let Err(e) = request.host.base.validate() {
        tracing::error!("Host validation failed: {:?}", e);
        return Err(ApiError::bad_request(&format!(
            "Host validation failed: {}",
            e
        )));
    }

    for service in &request.services {
        if let Err(e) = service.base.validate() {
            tracing::error!("Service validation failed: {:?}", e);
            return Err(ApiError::bad_request(&format!(
                "Service validation failed: {}",
                e
            )));
        }
    }

    let (host, services) = host_service
        .create_host_with_services(request.host, request.services)
        .await?;

    Ok(Json(ApiResponse::success(HostWithServicesRequest {
        host,
        services,
    })))
}

async fn get_all_hosts(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser
) -> ApiResult<Json<ApiResponse<Vec<Host>>>> {

    let service = &state.services.host_service;

    let network_ids: Vec<Uuid> = state.services.network_service
        .get_all_networks(&user.user_id)
        .await?
        .iter()
        .map(|n| n.id)
        .collect();

    let hosts = service.get_all_hosts(&network_ids).await?;

    Ok(Json(ApiResponse::success(hosts)))
}

async fn update_host(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(mut request): Json<HostWithServicesRequest>,
) -> ApiResult<Json<ApiResponse<Host>>> {
    let host_service = &state.services.host_service;
    let service_service = &state.services.service_service;

    let (create_futures, update_futures): (Vec<_>, Vec<_>) =
        request.services.into_iter().partition_map(|s| {
            if s.id == Uuid::nil() {
                let service = Service::new(s.base);
                Either::Left(service_service.create_service(service))
            } else {
                Either::Right(service_service.update_service(s))
            }
        });

    let created_services = try_join_all(create_futures).await?;
    let updated_services = try_join_all(update_futures).await?;

    request.host.base.services = created_services
        .iter()
        .chain(updated_services.iter())
        .map(|s| s.id)
        .collect();

    let updated_host = host_service.update_host(request.host).await?;

    Ok(Json(ApiResponse::success(updated_host)))
}

async fn consolidate_hosts(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path((destination_host_id, other_host_id)): Path<(Uuid, Uuid)>,
) -> ApiResult<Json<ApiResponse<Host>>> {
    let host_service = &state.services.host_service;

    let destination_host = host_service
        .get_host(&destination_host_id)
        .await?
        .ok_or_else(|| {
            ApiError::not_found(format!(
                "Could not find destination host {}",
                destination_host_id
            ))
        })?;
    let other_host = host_service
        .get_host(&other_host_id)
        .await?
        .ok_or_else(|| {
            ApiError::not_found(format!(
                "Could not find host to consolidate {}",
                other_host_id
            ))
        })?;

    let updated_host = host_service
        .consolidate_hosts(destination_host, other_host)
        .await?;

    Ok(Json(ApiResponse::success(updated_host)))
}

async fn delete_host(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.host_service;

    // Check if host exists
    if service.get_host(&id).await?.is_none() {
        return Err(ApiError::not_found(format!("Host '{}' not found", &id)));
    }

    service.delete_host(&id, true).await?;

    Ok(Json(ApiResponse::success(())))
}
