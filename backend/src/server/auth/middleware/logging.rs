use axum::{
    extract::{FromRequestParts, MatchedPath, Request, State},
    middleware::Next,
    response::Response,
};
use axum_client_ip::ClientIp;
use std::{sync::Arc, time::Instant};

use crate::server::{auth::middleware::auth::AuthenticatedEntity, config::AppState};

pub async fn request_logging_middleware(
    State(state): State<Arc<AppState>>,
    ClientIp(ip): ClientIp,
    request: Request,
    next: Next,
) -> Response {
    let start = Instant::now();

    // Extract info before consuming request
    let method = request.method().clone();
    let uri = request.uri().clone();
    let path = request
        .extensions()
        .get::<MatchedPath>()
        .map(|p| p.as_str().to_owned())
        .unwrap_or_else(|| uri.path().to_owned());

    // Extract auth info
    let (mut parts, body) = request.into_parts();
    let entity = AuthenticatedEntity::from_request_parts(&mut parts, &state)
        .await
        .ok();

    let (entity_type, entity_id) = match &entity {
        Some(AuthenticatedEntity::User { user_id, .. }) => ("user", Some(user_id.to_string())),
        Some(AuthenticatedEntity::Daemon { daemon_id, .. }) => {
            ("daemon", Some(daemon_id.to_string()))
        }
        Some(AuthenticatedEntity::System) => ("system", None),
        Some(AuthenticatedEntity::Anonymous) | None => ("anonymous", None),
    };

    let request = Request::from_parts(parts, body);

    // Process request
    let response = next.run(request).await;

    // Capture response info
    let duration = start.elapsed();
    let status = response.status().as_u16();

    // Log the request
    tracing::debug!(
        target: "request_log",
        method = %method,
        path = %path,
        status = status,
        duration_ms = duration.as_millis() as u64,
        ip = %ip,
        entity_type = entity_type,
        entity_id = entity_id,
        "request completed"
    );

    response
}
