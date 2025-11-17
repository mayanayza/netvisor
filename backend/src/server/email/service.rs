use anyhow::Error;
use email_address::EmailAddress;
use lettre::{
    SmtpTransport, Transport, message::Mailbox, transport::smtp::authentication::Credentials,
};

#[derive(Clone)]
pub struct EmailService {
    mailer: SmtpTransport,
    email: Mailbox,
}

impl EmailService {
    pub fn new(
        smtp_username: String,
        smtp_password: String,
        smtp_email: String,
        smtp_relay: String,
    ) -> Self {
        let creds = Credentials::new(smtp_username, smtp_password);

        EmailService {
            mailer: SmtpTransport::relay(&smtp_relay)
                .unwrap()
                .credentials(creds)
                .build(),
            email: Mailbox::new(None, smtp_email.parse().unwrap()),
        }
    }

    pub fn send_email(&self, to: EmailAddress, subject: &str, body: &str) -> Result<(), Error> {
        let to_mbox = Mailbox::new(
            None,
            to.email()
                .parse()
                .map_err(|e| Error::msg(format!("Invalid email address: {}", e)))?,
        );

        let email = lettre::Message::builder()
            .from(self.email.clone())
            .to(to_mbox)
            .subject(subject)
            .body(body.to_string())?;

        self.mailer.send(&email)?;

        Ok(())
    }
}
