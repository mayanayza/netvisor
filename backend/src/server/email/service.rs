use anyhow::{Result, anyhow};
use email_address::EmailAddress;
use lettre::{
    AsyncSmtpTransport, AsyncTransport, Tokio1Executor,
    message::{Mailbox, MultiPart, SinglePart},
    transport::smtp::authentication::Credentials,
};

#[derive(Clone)]
pub struct EmailService {
    mailer: AsyncSmtpTransport<Tokio1Executor>,
    from: Mailbox,
}

impl EmailService {
    pub fn new(
        smtp_username: String,
        smtp_password: String,
        smtp_email: String,
        smtp_relay: String,
    ) -> Result<Self> {
        let creds = Credentials::new(smtp_username, smtp_password);

        let mailer = AsyncSmtpTransport::<Tokio1Executor>::relay(&smtp_relay)
            .map_err(|e| anyhow!("Failed to create SMTP transport: {}", e))?
            .credentials(creds)
            .build();

        let from = Mailbox::new(
            Some("NetVisor".to_string()),
            smtp_email
                .parse()
                .map_err(|e| anyhow!("Invalid from email address: {}", e))?,
        );

        Ok(EmailService { mailer, from })
    }

    /// Send an HTML email
    pub async fn send_email(&self, to: EmailAddress, subject: &str, html_body: &str) -> Result<()> {
        let to_mbox = Mailbox::new(
            None,
            to.email()
                .parse()
                .map_err(|e| anyhow!("Invalid recipient email address: {}", e))?,
        );

        let email = lettre::Message::builder()
            .from(self.from.clone())
            .to(to_mbox)
            .subject(subject)
            .multipart(
                MultiPart::alternative()
                    .singlepart(SinglePart::plain(strip_html_tags(html_body)))
                    .singlepart(SinglePart::html(html_body.to_string())),
            )?;

        self.mailer
            .send(email)
            .await
            .map_err(|e| anyhow!("Failed to send email: {}", e))?;

        Ok(())
    }
}

/// Strip HTML tags for plain text fallback
fn strip_html_tags(html: &str) -> String {
    html2text::from_read(html.as_bytes(), 80).unwrap_or_else(|_| html.to_string())
}
