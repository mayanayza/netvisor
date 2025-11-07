use crate::server::auth::middleware::{AuthenticatedEntity, AuthenticatedUser};
use crate::server::shared::handlers::traits::{delete_handler, get_all_handler, get_by_id_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::{
    config::AppState,
    hosts::r#impl::{api::HostWithServicesRequest, base::Host},
    services::r#impl::base::Service,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::routing::{delete, get};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{post, put},
};
use futures::future::try_join_all;
use itertools::{Either, Itertools};
use std::sync::Arc;
use uuid::Uuid;
use validator::Validate;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_handler::<Host>))
        .route("/{id}", delete(delete_handler::<Host>))
        .route("/{id}", get(get_by_id_handler::<Host>))
        .route("/", post(create_host))
        .route("/{id}", put(update_host))
        .route(
            "/{destination_host}/consolidate/{other_host}",
            put(consolidate_hosts),
        )
}

async fn create_host(
    State(state): State<Arc<AppState>>,
    _authenticated: AuthenticatedEntity,
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

    let (host, services) = host_service
        .create_host_with_services(request.host, request.services.unwrap_or_default())
        .await?;

    Ok(Json(ApiResponse::success(HostWithServicesRequest {
        host,
        services: Some(services),
    })))
}

async fn update_host(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(mut request): Json<HostWithServicesRequest>,
) -> ApiResult<Json<ApiResponse<Host>>> {
    let host_service = &state.services.host_service;
    let service_service = &state.services.service_service;

    // If services is None, don't update services
    if let Some(services) = request.services {
        let (create_futures, update_futures): (Vec<_>, Vec<_>) =
            services.into_iter().partition_map(|s| {
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
    }

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

    let updated_host = host_service
        .consolidate_hosts(destination_host, other_host)
        .await?;

    Ok(Json(ApiResponse::success(updated_host)))
}
