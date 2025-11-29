use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::traits::{
    CrudHandlers, bulk_delete_handler, get_all_handler, get_by_id_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
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
use std::sync::Arc;
use uuid::Uuid;
use validator::Validate;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_handler::<Host>))
        .route("/{id}", delete(delete_handler))
        .route("/{id}", get(get_by_id_handler::<Host>))
        .route("/", post(create_host))
        .route("/{id}", put(update_host))
        .route("/bulk-delete", post(bulk_delete_handler::<Host>))
        .route(
            "/{destination_host}/consolidate/{other_host}",
            put(consolidate_hosts),
        )
}

async fn create_host(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { entity, .. }: MemberOrDaemon,
    Json(request): Json<HostWithServicesRequest>,
) -> ApiResult<Json<ApiResponse<HostWithServicesRequest>>> {
    let host_service = &state.services.host_service;

    if let Err(e) = request.host.base.validate() {
        tracing::warn!(
            error = %e,
            host_name = %request.host.base.name,
            "Host validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "Host validation failed: {}",
            e
        )));
    }

    let (host, services) = host_service
        .create_host_with_services(request.host, request.services.unwrap_or_default(), entity)
        .await?;

    Ok(Json(ApiResponse::success(HostWithServicesRequest {
        host,
        services: Some(services),
    })))
}

async fn update_host(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut request): Json<HostWithServicesRequest>,
) -> ApiResult<Json<ApiResponse<Host>>> {
    let host_service = &state.services.host_service;
    let service_service = &state.services.service_service;

    // If services is None, don't update services
    if let Some(services) = request.services {
        let mut created_service_ids = Vec::new();
        let mut updated_service_ids = Vec::new();
        let mut create_futures = Vec::new();

        for mut s in services {
            let user = user.clone();
            if s.id == Uuid::nil() {
                let service = Service::new(s.base);
                create_futures.push(service_service.create(service, user.into()));
            } else {
                // Execute updates sequentially
                let updated = service_service.update(&mut s, user.into()).await?;
                updated_service_ids.push(updated.id);
            }
        }

        // Execute creates concurrently
        let created_services = try_join_all(create_futures).await?;
        created_service_ids.extend(created_services.iter().map(|s| s.id));

        request.host.base.services = created_service_ids
            .into_iter()
            .chain(updated_service_ids)
            .collect();
    }

    let updated_host = host_service.update(&mut request.host, user.into()).await?;

    Ok(Json(ApiResponse::success(updated_host)))
}

async fn consolidate_hosts(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
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
        .consolidate_hosts(destination_host, other_host, user.into())
        .await?;

    Ok(Json(ApiResponse::success(updated_host)))
}

pub async fn delete_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = Host::get_service(&state);

    let daemon_service = &state.services.daemon_service;

    let host_filter = EntityFilter::unfiltered().host_id(&id);
    if daemon_service.get_one(host_filter).await?.is_some() {
        return Err(ApiError::conflict(
            "Can't delete a host with an associated daemon. Delete the daemon first.",
        ));
    }

    // Verify entity exists
    service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("Host '{}' not found", id)))?;

    service
        .delete(&id, user.into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(())))
}
