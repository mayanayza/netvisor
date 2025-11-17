use anyhow::{Result, anyhow};
use email_address::EmailAddress;
use lettre::{
    SmtpTransport, Transport,
    message::{Mailbox, MultiPart, SinglePart},
    transport::smtp::authentication::Credentials,
};

#[derive(Clone)]
pub struct EmailService {
    mailer: SmtpTransport,
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

        let mailer = SmtpTransport::relay(&smtp_relay)
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
    pub fn send_email(&self, to: EmailAddress, subject: &str, html_body: &str) -> Result<()> {
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
            .send(&email)
            .map_err(|e| anyhow!("Failed to send email: {}", e))?;

        Ok(())
    }
}

/// Strip HTML tags for plain text fallback
fn strip_html_tags(html: &str) -> String {
    // Basic HTML stripping - you might want a proper library for this
    html.replace("<br>", "\n")
        .replace("<br/>", "\n")
        .replace("<br />", "\n")
        .chars()
        .fold((String::new(), false), |(mut text, in_tag), c| match c {
            '<' => (text, true),
            '>' => (text, false),
            c if !in_tag => {
                text.push(c);
                (text, false)
            }
            _ => (text, in_tag),
        })
        .0
        .trim()
        .to_string()
}
