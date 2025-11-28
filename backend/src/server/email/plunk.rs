use crate::server::email::{templates::PASSWORD_RESET_TITLE, traits::EmailProvider};
use anyhow::Error;
use anyhow::anyhow;
use async_trait::async_trait;
use email_address::EmailAddress;
use plunk::{PlunkClient, PlunkClientTrait, PlunkPayloads};
use reqwest::Client;
use serde_json::Value;

/// Plunk-based email provider
pub struct PlunkEmailProvider {
    api_key: String,
    client: Client,
    plunk: PlunkClient,
}

impl PlunkEmailProvider {
    pub fn new(api_key: String) -> Self {
        Self {
            plunk: PlunkClient::new(api_key.clone()),
            api_key,
            client: Client::new(),
        }
    }
}

#[async_trait]
impl EmailProvider for PlunkEmailProvider {
    async fn send_password_reset(
        &self,
        to: EmailAddress,
        url: String,
        token: String,
    ) -> Result<(), Error> {
        self.plunk
            .send_transactional_email(PlunkPayloads {
                to: to.to_string(),
                subject: Some(PASSWORD_RESET_TITLE.to_string()),
                body: self.build_password_reset_email(url, token),
            })
            .await
            .map_err(|e| anyhow!("{}", e))
            .map(|_| ())
    }

    /// Send an invite via email
    async fn send_invite(
        &self,
        to: EmailAddress,
        from: EmailAddress,
        url: String,
    ) -> Result<(), Error> {
        self.plunk
            .send_transactional_email(PlunkPayloads {
                to: to.to_string(),
                subject: Some(self.build_invite_title(from.clone())),
                body: self.build_invite_email(url, from),
            })
            .await
            .map_err(|e| anyhow!("{}", e))
            .map(|_| ())
    }

    async fn track_event(
        &self,
        event: String,
        email: EmailAddress,
        subscribed: bool,
        data: Value,
    ) -> Result<(), Error> {
        // Convert all values in the object to strings
        let normalized_data = if let Value::Object(map) = data {
            let stringified: serde_json::Map<String, Value> = map
                .into_iter()
                .map(|(k, v)| {
                    let string_value = match v {
                        Value::String(s) => Value::String(s),
                        other => Value::String(serde_json::to_string(&other).unwrap_or_default()),
                    };
                    (k, string_value)
                })
                .collect();
            Value::Object(stringified)
        } else {
            serde_json::json!({})
        };

        let body = serde_json::json!({
            "event": event,
            "email": email.to_string(),
            "subscribed": subscribed,
            "data": normalized_data
        });

        let response = self
            .client
            .post("https://api.useplunk.com/v1/track")
            .header("Content-Type", "application/json")
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&body)
            .send()
            .await?;

        if response.status().is_success() {
            Ok(())
        } else {
            Err(anyhow!(
                "Failed to track Plunk event: {}",
                response.text().await?
            ))
        }
    }
}
