use lettre::{
    AsyncSmtpTransport, AsyncTransport, Tokio1Executor,
    message::{Mailbox, MultiPart, SinglePart},
    transport::smtp::authentication::Credentials,
};

use anyhow::{Error, anyhow};
use async_trait::async_trait;
use email_address::EmailAddress;

use crate::server::email::{
    templates::PASSWORD_RESET_TITLE,
    traits::{EmailProvider, strip_html_tags},
};

pub struct SmtpEmailProvider {
    mailer: AsyncSmtpTransport<Tokio1Executor>,
    from: Mailbox,
}

impl SmtpEmailProvider {
    pub fn new(
        smtp_username: String,
        smtp_password: String,
        smtp_email: String,
        smtp_relay: String,
    ) -> Result<Self, Error> {
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

        Ok(Self { mailer, from })
    }

    async fn send_email(&self, to: EmailAddress, title: String, body: String) -> Result<(), Error> {
        let to_mbox = Mailbox::new(
            None,
            to.email()
                .parse()
                .map_err(|e| anyhow!("Invalid recipient email address: {}", e))?,
        );

        let email = lettre::Message::builder()
            .from(self.from.clone())
            .to(to_mbox)
            .subject(title)
            .multipart(
                MultiPart::alternative()
                    .singlepart(SinglePart::plain(strip_html_tags(body.clone())))
                    .singlepart(SinglePart::html(body)),
            )?;

        self.mailer
            .send(email)
            .await
            .map_err(|e| anyhow!("Failed to send email: {}", e))?;

        Ok(())
    }
}

#[async_trait]
impl EmailProvider for SmtpEmailProvider {
    async fn send_invite(
        &self,
        to: EmailAddress,
        from: EmailAddress,
        url: String,
    ) -> Result<(), Error> {
        self.send_email(
            to,
            self.build_invite_title(from.clone()),
            self.build_invite_email(url, from),
        )
        .await
    }

    async fn send_password_reset(
        &self,
        to: EmailAddress,
        url: String,
        token: String,
    ) -> Result<(), Error> {
        self.send_email(
            to,
            PASSWORD_RESET_TITLE.to_string(),
            self.build_password_reset_email(url, token),
        )
        .await
    }
}
