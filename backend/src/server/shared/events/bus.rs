use std::{collections::HashMap, sync::Arc};

use tokio::sync::RwLock;

use anyhow::Result;
use async_trait::async_trait;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::server::shared::{
    entities::Entity,
    events::types::{EntityEvent, EntityOperation},
};

// Trait for event subscribers
#[async_trait]
pub trait EventSubscriber: Send + Sync {
    /// Return the types of events this subscriber cares about
    fn event_filter(&self) -> EventFilter;

    /// Handle an event
    async fn handle_event(&self, event: &EntityEvent) -> Result<()>;

    /// Optional: subscriber name for debugging
    fn name(&self) -> &str;
}

#[derive(Debug, Clone)]
pub struct EventFilter {
    pub entity_operations: Option<HashMap<Entity, Option<Vec<EntityOperation>>>>,
    pub network_ids: Option<Vec<Uuid>>,
}

impl EventFilter {
    pub fn all() -> Self {
        Self {
            entity_operations: None,
            network_ids: None,
        }
    }

    pub fn matches(&self, event: &EntityEvent) -> bool {
        if let Some(networks) = &self.network_ids
            && let Some(network_id) = event.network_id
            && !networks.contains(&network_id)
        {
            return false;
        }

        if let Some(entity_operations) = &self.entity_operations {
            if let Some(operations) = entity_operations.get(&event.entity_type) {
                if operations.is_none() {
                    return true;
                } else if let Some(operations) = operations
                    && operations.contains(&event.operation)
                {
                    return true;
                }
            }
            return false;
        }

        true
    }
}

pub struct EventBus {
    sender: broadcast::Sender<EntityEvent>,
    subscribers: Arc<RwLock<Vec<Arc<dyn EventSubscriber>>>>,
}

impl Default for EventBus {
    fn default() -> Self {
        Self::new()
    }
}

impl EventBus {
    pub fn new() -> Self {
        let (sender, _) = broadcast::channel(1000); // Buffer size

        Self {
            sender,
            subscribers: Arc::new(RwLock::new(Vec::new())),
        }
    }

    /// Register a subscriber
    pub async fn register_subscriber(&self, subscriber: Arc<dyn EventSubscriber>) {
        let mut subscribers = self.subscribers.write().await;
        subscribers.push(subscriber.clone());
        tracing::info!(
            subscriber = %subscriber.name(),
            "Registered event subscriber",
        );
    }

    /// Publish an event to all subscribers
    pub async fn publish(&self, event: EntityEvent) -> Result<()> {
        tracing::debug!(
            operation = %event.operation,
            entity_type = %event.entity_type,
            entity_id = %event.entity_id,
            "Publishing event",
        );

        // Send to broadcast channel (non-blocking)
        let _ = self.sender.send(event.clone());

        // Also notify direct subscribers (blocking, with error handling)
        let subscribers = self.subscribers.read().await;

        for subscriber in subscribers.iter() {
            if subscriber.event_filter().matches(&event)
                && let Err(e) = subscriber.handle_event(&event).await
            {
                tracing::error!(
                    subscriber = subscriber.name(),
                    error = %e,
                    "Subscriber failed to handle event",
                );
            }
        }

        Ok(())
    }

    /// Get a receiver for raw event stream (useful for SSE)
    pub fn subscribe_channel(&self) -> broadcast::Receiver<EntityEvent> {
        self.sender.subscribe()
    }
}
