use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    email::traits::EmailService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::{AuthOperation, Event},
    },
};
use anyhow::Error;
use async_trait::async_trait;
use serde_json::Value;
use std::collections::HashMap;

#[async_trait]
impl EventSubscriber for EmailService {
    fn event_filter(&self) -> EventFilter {
        EventFilter {
            entity_operations: Some(HashMap::new()),
            auth_operations: Some(vec![AuthOperation::Register]),
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
                let metadata = event.metadata();
                let operation = event.operation();

                let mut metadata_map: HashMap<String, Value> = serde_json::from_value(metadata)?;

                let subscribed = metadata_map
                    .remove("subscribed")
                    .map(|v| serde_json::from_value::<bool>(v).unwrap_or(false))
                    .unwrap_or(false);

                let metadata = serde_json::to_value(metadata_map)?;

                self.track_event(
                    operation.to_string().to_lowercase(),
                    email,
                    subscribed,
                    metadata,
                )
                .await?;
            };
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "email_triggers"
    }
}
