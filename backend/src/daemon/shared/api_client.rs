use crate::daemon::shared::config::ConfigStore;
use crate::server::shared::types::api::ApiResponse;
use anyhow::{Error, bail};
use reqwest::{Client, Method, RequestBuilder};
use serde::{Serialize, de::DeserializeOwned};
use std::sync::Arc;
use tokio::sync::OnceCell;

pub struct DaemonApiClient {
    config_store: Arc<ConfigStore>,
    client: OnceCell<Client>,
}

impl DaemonApiClient {
    pub fn new(config_store: Arc<ConfigStore>) -> Self {
        Self {
            config_store,
            client: OnceCell::new(),
        }
    }

    /// Get or lazily initialize the HTTP client
    async fn get_client(&self) -> Result<&Client, Error> {
        self.client
            .get_or_try_init(|| async {
                let allow_self_signed_certs =
                    self.config_store.get_allow_self_signed_certs().await?;

                Client::builder()
                    .danger_accept_invalid_certs(allow_self_signed_certs)
                    .build()
                    .map_err(|e| anyhow::anyhow!("Failed to build HTTP client: {}", e))
            })
            .await
    }

    /// Build a request with standard daemon auth headers
    async fn build_request(&self, method: Method, path: &str) -> Result<RequestBuilder, Error> {
        let client = self.get_client().await?;
        let server_target = self.config_store.get_server_url().await?;
        let daemon_id = self.config_store.get_id().await?;
        let api_key = self
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let url = format!("{}{}", server_target, path);

        Ok(client
            .request(method, &url)
            .header("X-Daemon-ID", daemon_id.to_string())
            .header("Authorization", format!("Bearer {}", api_key)))
    }

    /// Execute request and parse ApiResponse, extracting data
    async fn execute<T: DeserializeOwned>(
        &self,
        request: RequestBuilder,
        context: &str,
    ) -> Result<T, Error> {
        let response = request.send().await?;

        if !response.status().is_success() {
            bail!("{}: HTTP {}", context, response.status());
        }

        let api_response: ApiResponse<T> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            bail!("{}: {}", context, error_msg);
        }

        api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("{}: No data in response", context))
    }

    /// GET request
    pub async fn get<T: DeserializeOwned>(&self, path: &str, context: &str) -> Result<T, Error> {
        let request = self.build_request(Method::GET, path).await?;
        self.execute(request, context).await
    }

    /// POST request with JSON body
    pub async fn post<B: Serialize, T: DeserializeOwned>(
        &self,
        path: &str,
        body: &B,
        context: &str,
    ) -> Result<T, Error> {
        let request = self.build_request(Method::POST, path).await?.json(body);
        self.execute(request, context).await
    }

    /// POST request expecting no response data (returns () on success)
    pub async fn post_no_response<B: Serialize>(
        &self,
        path: &str,
        body: &B,
        context: &str,
    ) -> Result<(), Error> {
        let request = self.build_request(Method::POST, path).await?.json(body);
        let response = request.send().await?;

        if !response.status().is_success() {
            bail!("{}: HTTP {}", context, response.status());
        }

        Ok(())
    }

    /// POST request returning full ApiResponse for custom error handling
    pub async fn post_raw<B: Serialize, T: DeserializeOwned>(
        &self,
        path: &str,
        body: &B,
    ) -> Result<ApiResponse<T>, Error> {
        let request = self.build_request(Method::POST, path).await?.json(body);
        let response = request.send().await?;
        Ok(response.json().await?)
    }

    /// POST with no body, returning full ApiResponse
    pub async fn post_empty_raw<T: DeserializeOwned>(
        &self,
        path: &str,
    ) -> Result<ApiResponse<T>, Error> {
        let request = self.build_request(Method::POST, path).await?;
        let response = request.send().await?;
        Ok(response.json().await?)
    }

    /// Access config store for cases that need custom handling
    pub fn config(&self) -> &Arc<ConfigStore> {
        &self.config_store
    }
}
