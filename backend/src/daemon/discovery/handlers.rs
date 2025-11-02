use crate::daemon::discovery::manager::DaemonDiscoverySessionManager;
use crate::daemon::discovery::service::base::{Discovery, RunsDiscovery};
use crate::daemon::discovery::service::docker::DockerScanDiscovery;
use crate::daemon::discovery::service::network::NetworkScanDiscovery;
use crate::daemon::discovery::service::self_report::SelfReportDiscovery;
use crate::daemon::runtime::types::DaemonAppState;
use crate::server::daemons::types::api::{
    DaemonDiscoveryCancellationRequest, DaemonDiscoveryCancellationResponse,
};
use crate::server::discovery::types::base::DiscoveryType;
use crate::server::{
    daemons::types::api::{DaemonDiscoveryRequest, DaemonDiscoveryResponse},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{Router, extract::State, response::Json, routing::post};
use std::sync::Arc;
use tokio_util::sync::CancellationToken;

pub fn create_router() -> Router<Arc<DaemonAppState>> {
    Router::new()
        .route("/initiate", post(handle_discovery_request))
        .route("/cancel", post(handle_cancel_request))
}

async fn handle_discovery_request(
    State(state): State<Arc<DaemonAppState>>,
    Json(request): Json<DaemonDiscoveryRequest>,
) -> ApiResult<Json<ApiResponse<DaemonDiscoveryResponse>>> {
    let session_id = request.session_id;
    tracing::info!(
        "Received {} discovery request, session ID {}",
        request.discovery_type,
        request.session_id
    );

    let manager = state.services.discovery_manager.clone();
    let cancel_token = manager.start_new_session().await;

    let handle = match request.discovery_type {
        DiscoveryType::SelfReport { host_id } => spawn_discovery(
            Discovery::new(
                state.services.discovery_service.clone(),
                state.services.discovery_manager.clone(),
                SelfReportDiscovery::new(host_id),
            ),
            request.clone(),
            cancel_token,
            manager.clone(),
        ),
        DiscoveryType::Docker { host_id } => spawn_discovery(
            Discovery::new(
                state.services.discovery_service.clone(),
                state.services.discovery_manager.clone(),
                DockerScanDiscovery::new(host_id),
            ),
            request.clone(),
            cancel_token,
            manager.clone(),
        ),
        DiscoveryType::Network { .. } => spawn_discovery(
            Discovery::new(
                state.services.discovery_service.clone(),
                state.services.discovery_manager.clone(),
                NetworkScanDiscovery::new(),
            ),
            request.clone(),
            cancel_token,
            manager.clone(),
        ),
    };

    manager.set_current_task(handle).await;

    Ok(Json(ApiResponse::success(DaemonDiscoveryResponse {
        session_id,
    })))
}

fn spawn_discovery<T>(
    discovery: Discovery<T>,
    request: DaemonDiscoveryRequest,
    cancel_token: CancellationToken,
    manager: Arc<DaemonDiscoverySessionManager>,
) -> tokio::task::JoinHandle<()>
where
    Discovery<T>: RunsDiscovery + 'static,
    T: 'static + Send + Sync,
{
    tokio::spawn(async move {
        match discovery.discover(request, cancel_token.clone()).await {
            Ok(()) => {
                tracing::info!("Discovery completed successfully");
            }
            Err(e) => {
                tracing::error!("Discovery failed: {}", e);
            }
        }
        // Only clear if NOT cancelled - the cancel handler will clear it
        if !cancel_token.is_cancelled() {
            manager.clear_completed_task().await;
        }
    })
}

async fn handle_cancel_request(
    State(state): State<Arc<DaemonAppState>>,
    Json(request): Json<DaemonDiscoveryCancellationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonDiscoveryCancellationResponse>>> {
    let session_id = request.session_id;
    tracing::info!(
        "Received discovery cancellation request for session {}",
        session_id
    );

    let manager = state.services.discovery_manager.clone();

    if manager.is_discovery_running().await {
        // Just signal cancellation, don't wait
        if manager.cancel_current_session().await {
            // Don't clear the task - let the spawned task do it
            Ok(Json(ApiResponse::success(
                DaemonDiscoveryCancellationResponse { session_id },
            )))
        } else {
            Err(ApiError::internal_error(
                "Failed to cancel discovery session",
            ))
        }
    } else {
        Err(ApiError::conflict(
            "Discovery session not currently running",
        ))
    }
}
