use crate::server::{
    api_keys::{
        r#impl::{api::ApiKeyResponse, base::ApiKey},
        service::generate_api_key_for_storage,
    },
    auth::middleware::{
        features::{BlockedInDemoMode, RequireFeature},
        permissions::RequireMember,
    },
    config::AppState,
    shared::{
        events::types::{TelemetryEvent, TelemetryOperation},
        handlers::{traits::{CrudHandlers, update_handler}},
        services::traits::{CrudService, EventBusService},
        types::api::{ApiError, ApiResponse, ApiResult},
    },
};
use axum::{
    Json,
    extract::{Path, State},
};
use axum_client_ip::ClientIp;
use axum_extra::{TypedHeader, headers::UserAgent};
use chrono::Utc;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

mod generated {
    use super::*;
    crate::crud_get_all_handler!(ApiKey, "api_keys", "api_key");
    crate::crud_get_by_id_handler!(ApiKey, "api_keys", "api_key");
    crate::crud_delete_handler!(ApiKey, "api_keys", "api_key");
    crate::crud_bulk_delete_handler!(ApiKey, "api_keys");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_api_key))
        .routes(routes!(generated::get_by_id, generated::delete))
        .routes(routes!(update_api_key))
        .routes(routes!(rotate_key_handler))
        .routes(routes!(generated::bulk_delete))
}

/// Create API key
#[utoipa::path(
    post,
    path = "",
    tag = "api_keys",
    responses(
        (status = 200, description = "API key created"),
    ),
    security(("session" = []))
)]
pub async fn create_api_key(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Json(mut api_key): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKeyResponse>>> {
    tracing::debug!(
        api_key_name = %api_key.base.name,
        network_id = %api_key.base.network_id,
        user_id = %user.user_id,
        "API key create request received"
    );

    let (plaintext, hashed) = generate_api_key_for_storage();

    let service = ApiKey::get_service(&state);
    api_key.base.key = hashed;
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
        key: plaintext,
        api_key,
    })))
}

/// Update an API key
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "api_keys",
    params(("id" = Uuid, Path, description = "API key ID")),
    responses(
        (status = 200, description = "API key updated"),
        (status = 404, description = "API key not found"),
    ),
    security(("session" = []))
)]
pub async fn update_api_key(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
    Json(mut request): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKey>>> {
    // Fetch existing to preserve immutable fields
    let existing = ApiKey::get_service(&state)
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("API key '{}' not found", id)))?;

    // Preserve the key hash - don't allow it to be changed via update
    request.base.key = existing.base.key;

    // Delegate to generic handler
    update_handler::<ApiKey>(State(state), user, Path(id), Json(request)).await
}

/// Rotate an API key
#[utoipa::path(
    post,
    path = "/{id}/rotate",
    tag = "api_keys",
    params(("id" = Uuid, Path, description = "API key ID")),
    responses(
        (status = 200, description = "API key rotated, returns new key"),
        (status = 404, description = "API key not found"),
    ),
    security(("session" = []))
)]
pub async fn rotate_key_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    _demo_check: RequireFeature<BlockedInDemoMode>,
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
