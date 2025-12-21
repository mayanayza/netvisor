use std::sync::Arc;

use anyhow::{Error, Result};
use async_trait::async_trait;
use email_address::EmailAddress;

use crate::server::{
    email::templates::{EMAIL_FOOTER, EMAIL_HEADER, INVITE_LINK_BODY, PASSWORD_RESET_BODY},
    users::service::UserService,
};

/// Trait for email provider implementations
#[async_trait]
pub trait EmailProvider: Send + Sync {
    // Example usage function
    fn build_email(&self, body: String) -> String {
        format!("{}{}{}", EMAIL_HEADER, body, EMAIL_FOOTER)
    }

    fn build_invite_title(&self, from_user: EmailAddress) -> String {
        format!("You've been invited to join {} on Scanopy", from_user)
    }

    fn build_password_reset_email(&self, url: String, token: String) -> String {
        self.build_email(PASSWORD_RESET_BODY.replace(
            "{reset_url}",
            &format!("{}/reset-password?token={}", url, token),
        ))
    }

    fn build_invite_email(&self, url: String, from: EmailAddress) -> String {
        self.build_email(
            INVITE_LINK_BODY
                .replace("{invite_url}", &url)
                .replace("{inviter_name}", from.as_str()),
        )
    }

    /// Send an HTML email
    async fn send_password_reset(
        &self,
        to: EmailAddress,
        url: String,
        token: String,
    ) -> Result<(), Error>;

    /// Send an invite via email
    async fn send_invite(
        &self,
        to: EmailAddress,
        from: EmailAddress,
        url: String,
    ) -> Result<(), Error>;

    /// Track an event (optional, only for providers that support it)
    async fn track_event(&self, event: String, email: EmailAddress) -> Result<()> {
        // Default implementation does nothing
        let _ = (event, email);
        Ok(())
    }
}

/// Email service that wraps the provider
pub struct EmailService {
    provider: Box<dyn EmailProvider>,
    pub user_service: Arc<UserService>,
}

impl EmailService {
    pub fn new(provider: Box<dyn EmailProvider>, user_service: Arc<UserService>) -> Self {
        Self {
            provider,
            user_service,
        }
    }

    /// Send an HTML email
    pub async fn send_password_reset(
        &self,
        to: EmailAddress,
        url: String,
        token: String,
    ) -> Result<()> {
        self.provider.send_password_reset(to, url, token).await
    }

    pub async fn send_invite(
        &self,
        to: EmailAddress,
        from: EmailAddress,
        url: String,
    ) -> Result<()> {
        self.provider.send_invite(to, from, url).await
    }

    /// Track an event (delegates to provider)
    pub async fn track_event(&self, event: String, email: EmailAddress) -> Result<()> {
        self.provider.track_event(event, email).await
    }
}

/// Strip HTML tags for plain text fallback
pub fn strip_html_tags(html: String) -> String {
    html2text::from_read(html.as_bytes(), 80).unwrap_or_else(|_| html.to_string())
}
