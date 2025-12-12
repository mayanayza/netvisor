use crate::server::email::{templates::PASSWORD_RESET_TITLE, traits::EmailProvider};
use anyhow::Error;
use anyhow::anyhow;
use async_trait::async_trait;
use email_address::EmailAddress;
// use plunk::{PlunkClient, PlunkClientTrait, PlunkPayloads};
use reqwest::Client;
use serde_json::json;

/// Plunk-based email provider
pub struct PlunkEmailProvider {
    api_key: String,
    client: Client,
}

impl PlunkEmailProvider {
    pub fn new(api_key: String) -> Self {
        Self {
            api_key,
            client: Client::new(),
        }
    }

    pub async fn send_transactional_email(
        &self,
        to: EmailAddress,
        subject: String,
        body: String,
    ) -> Result<(), Error> {
        let url = "https://api.useplunk.com/v1/send";
        let payload = json!({
            "to": to.to_string(),
            "subject": subject,
            "body": body,
            "name": "NetVisor",
            "from": "no-reply@email.netvisor.io",
            "reply": "no-reply@email.netvisor.io"
        });

        let response = self
            .client
            .post(url)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&payload)
            .send()
            .await?;

        if response.status().is_success() {
            Ok(())
        } else {
            Err(anyhow!(
                "Failed to send email via Plunk: {}",
                response.text().await?
            ))
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
        self.send_transactional_email(
            to,
            PASSWORD_RESET_TITLE.to_string(),
            self.build_password_reset_email(url, token),
        )
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
        self.send_transactional_email(
            to,
            self.build_invite_title(from.clone()),
            self.build_invite_email(url, from),
        )
        .await
        .map_err(|e| anyhow!("{}", e))
        .map(|_| ())
    }

    async fn track_event(
        &self,
        event: String,
        email: EmailAddress,
        subscribed: bool,
    ) -> Result<(), Error> {
        let body = serde_json::json!({
            "event": event,
            "email": email.to_string(),
            "subscribed": subscribed,
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
