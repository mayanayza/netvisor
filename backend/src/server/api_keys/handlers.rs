use crate::server::{
    api_keys::r#impl::{api::ApiKeyResponse, base::ApiKey},
    auth::middleware::permissions::RequireMember,
    config::AppState,
    shared::{
        events::types::{TelemetryEvent, TelemetryOperation},
        handlers::traits::{
            CrudHandlers, bulk_delete_handler, delete_handler, get_all_handler, get_by_id_handler,
        },
        services::traits::{CrudService, EventBusService},
        types::api::{ApiError, ApiResponse, ApiResult},
    },
};
use axum::{
    Json, Router,
    extract::{Path, State},
    routing::{delete, get, post, put},
};
use axum_client_ip::ClientIp;
use axum_extra::{TypedHeader, headers::UserAgent};
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_handler::<ApiKey>))
        .route("/", post(create_handler))
        .route("/{id}/rotate", post(rotate_key_handler))
        .route("/{id}", put(update_handler))
        .route("/{id}", delete(delete_handler::<ApiKey>))
        .route("/{id}", get(get_by_id_handler::<ApiKey>))
        .route("/bulk-delete", post(bulk_delete_handler::<ApiKey>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut api_key): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKeyResponse>>> {
    tracing::debug!(
        api_key_name = %api_key.base.name,
        network_id = %api_key.base.network_id,
        user_id = %user.user_id,
        "API key create request received"
    );

    let service = ApiKey::get_service(&state);
    api_key.base.key = service.generate_api_key();
    let api_key = service
        .create(api_key, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                error = %e,
                user_id = %user.user_id,
                "Failed to create API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    let organization = state
        .services
        .organization_service
        .get_by_id(&user.organization_id)
        .await?;

    if let Some(organization) = organization
        && organization.not_onboarded(&TelemetryOperation::FirstApiKeyCreated)
    {
        service
            .event_bus()
            .publish_telemetry(TelemetryEvent {
                id: Uuid::new_v4(),
                authentication: user.clone().into(),
                organization_id: user.organization_id,
                operation: TelemetryOperation::FirstApiKeyCreated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "is_onboarding_step": true
                }),
            })
            .await?;
    }

    Ok(Json(ApiResponse::success(ApiKeyResponse {
        key: api_key.base.key.clone(),
        api_key,
    })))
}

pub async fn rotate_key_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    Path(api_key_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let user_agent = user_agent.map(|u| u.to_string());

    let service = ApiKey::get_service(&state);
    let key = service
        .rotate_key(api_key_id, ip, user_agent, user.clone())
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %api_key_id,
                user_id = %user.user_id,
                error = %e,
                "Failed to rotate API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(key)))
}

pub async fn update_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut request): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKey>>> {
    tracing::debug!(
        api_key_id = %id,
        user_id = %user.user_id,
        "API key update request received"
    );

    let service = ApiKey::get_service(&state);

    // Verify entity exists
    let existing = service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to fetch API key for update"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                api_key_id = %id,
                user_id = %user.user_id,
                "API key not found for update"
            );
            ApiError::not_found(format!("Api Key '{}' not found", id))
        })?;

    // Preserve the key - don't allow it to be changed via update
    request.base.key = existing.base.key;

    let updated = service
        .update(&mut request, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to update API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(updated)))
}
