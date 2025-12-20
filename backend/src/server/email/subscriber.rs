use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    email::traits::EmailService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::Event,
    },
};
use anyhow::Error;
use async_trait::async_trait;
use std::collections::HashMap;

#[async_trait]
impl EventSubscriber for EmailService {
    fn event_filter(&self) -> EventFilter {
        EventFilter {
            entity_operations: Some(HashMap::new()),
            auth_operations: Some(vec![]),
            telemetry_operations: None,
            network_ids: Some(vec![]),
        }
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        for event in events {
            if let AuthenticatedEntity::User { email, .. } = event.authentication() {
                let operation = event.operation();

                self.track_event(operation.to_string().to_lowercase(), email)
                    .await?;
            };
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "email_triggers"
    }
}
