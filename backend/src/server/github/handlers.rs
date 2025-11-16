use axum::{Extension, Json, http::StatusCode};
use reqwest;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::server::shared::{handlers::cache::AppCache, types::api::ApiResponse};

#[derive(Serialize, Deserialize)]
struct GitHubRepoResponse {
    stargazers_count: u32,
}

const CACHE_KEY: &str = "github_stars";

pub async fn get_stars(
    Extension(cache): Extension<Arc<AppCache>>,
) -> Result<Json<ApiResponse<u32>>, StatusCode> {
    // Check cache first
    if let Some(cached) = cache.get::<u32>(CACHE_KEY).await {
        return Ok(Json(ApiResponse::success(cached)));
    }

    // Cache miss - fetch from GitHub
    let client = reqwest::Client::new();
    let request = client
        .get("https://api.github.com/repos/mayanayza/netvisor")
        .header("User-Agent", "NetVisor");

    match request.send().await {
        Ok(response) => {
            if !response.status().is_success() {
                tracing::error!("GitHub API error: {}", response.status());
                return Err(StatusCode::BAD_GATEWAY);
            }

            match response.json::<GitHubRepoResponse>().await {
                Ok(data) => {
                    // Cache for 6 hours
                    cache.set(CACHE_KEY, data.stargazers_count, 6).await;

                    Ok(Json(ApiResponse::success(data.stargazers_count)))
                }
                Err(e) => {
                    tracing::error!("Failed to parse GitHub response: {}", e);
                    Err(StatusCode::BAD_GATEWAY)
                }
            }
        }
        Err(e) => {
            tracing::error!("Failed to fetch from GitHub: {}", e);
            Err(StatusCode::BAD_GATEWAY)
        }
    }
}
