use std::{collections::HashMap, sync::Arc, time::Duration};

use strum::IntoDiscriminant;
use tokio::sync::RwLock;

use anyhow::Result;
use async_trait::async_trait;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::server::shared::{
    entities::EntityDiscriminants,
    events::types::{AuthEvent, AuthOperation, EntityEvent, EntityOperation, Event},
};

// Trait for event subscribers
#[async_trait]
pub trait EventSubscriber: Send + Sync {
    /// Return the types of events this subscriber cares about
    fn event_filter(&self) -> EventFilter;

    /// Handle a batch of events (vec will have 1 element if debounce_window_ms = 0)
    async fn handle_events(&self, events: Vec<Event>) -> Result<()>;

    /// Optional: debounce window in milliseconds (default: 0 = no batching)
    fn debounce_window_ms(&self) -> u64 {
        0
    }

    /// Optional: subscriber name for debugging
    fn name(&self) -> &str;
}

#[derive(Debug, Clone)]
pub struct EventFilter {
    // None = match all values (ignore as a filter)
    pub entity_operations: Option<HashMap<EntityDiscriminants, Option<Vec<EntityOperation>>>>,
    pub auth_operations: Option<Vec<AuthOperation>>,
    pub network_ids: Option<Vec<Uuid>>,
}

impl EventFilter {
    pub fn all() -> Self {
        Self {
            entity_operations: None,
            auth_operations: None,
            network_ids: None,
        }
    }

    pub fn entity_only(
        entity_operations: HashMap<EntityDiscriminants, Option<Vec<EntityOperation>>>,
    ) -> Self {
        Self {
            entity_operations: Some(entity_operations),
            auth_operations: None,
            network_ids: None,
        }
    }

    pub fn auth_only(auth_operations: Vec<AuthOperation>) -> Self {
        Self {
            entity_operations: None,
            auth_operations: Some(auth_operations),
            network_ids: None,
        }
    }

    pub fn matches(&self, event: &Event) -> bool {
        match event {
            Event::Entity(entity_event) => self.matches_entity(entity_event),
            Event::Auth(auth_event) => self.matches_auth(auth_event),
        }
    }

    fn matches_entity(&self, event: &EntityEvent) -> bool {
        // Check network filter
        if let Some(networks) = &self.network_ids
            && let Some(network_id) = event.network_id
            && !networks.contains(&network_id)
        {
            return false;
        }

        // Check entity operation filter
        if let Some(entity_operations) = &self.entity_operations {
            if let Some(operations) = entity_operations.get(&event.entity_type.discriminant()) {
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

    fn matches_auth(&self, event: &AuthEvent) -> bool {
        // Check network filter (using organization_id for auth events)
        if let Some(networks) = &self.network_ids
            && let Some(org_id) = event.organization_id
            && !networks.contains(&org_id)
        {
            return false;
        }

        // Check auth operation filter
        if let Some(auth_operations) = &self.auth_operations {
            return auth_operations.contains(&event.operation);
        }

        true
    }
}

/// Internal: Manages batching state for a subscriber
struct SubscriberState {
    subscriber: Arc<dyn EventSubscriber>,
    pending_events: Arc<RwLock<Vec<Event>>>,
}

impl SubscriberState {
    fn new(subscriber: Arc<dyn EventSubscriber>) -> Self {
        let debounce_ms = subscriber.debounce_window_ms();
        let pending = Arc::new(RwLock::new(Vec::new()));

        if debounce_ms > 0 {
            // Spawn background flush task for subscribers with batching
            let pending_clone = pending.clone();
            let subscriber_clone = subscriber.clone();
            let debounce_window = Duration::from_millis(debounce_ms);

            tokio::spawn(async move {
                let mut interval = tokio::time::interval(debounce_window);
                loop {
                    interval.tick().await;
                    Self::flush_batch(&subscriber_clone, &pending_clone).await;
                }
            });
        }

        Self {
            subscriber,
            pending_events: pending,
        }
    }

    async fn flush_batch(subscriber: &Arc<dyn EventSubscriber>, pending: &Arc<RwLock<Vec<Event>>>) {
        let events: Vec<Event> = {
            let mut p = pending.write().await;
            if p.is_empty() {
                return;
            }

            // Deduplicate events (requires PartialEq on Event)
            let mut unique_events = Vec::new();
            for event in p.drain(..) {
                if !unique_events.contains(&event) {
                    unique_events.push(event);
                }
            }
            unique_events
        };

        if events.is_empty() {
            return;
        }

        tracing::debug!(
            subscriber = %subscriber.name(),
            event_count = events.len(),
            "Subscriber processing event batch"
        );

        if let Err(e) = subscriber.handle_events(events).await {
            tracing::error!(
                subscriber = %subscriber.name(),
                error = %e,
                "Subscriber failed to handle batched events",
            );
        }
    }

    async fn add_event(&self, event: Event) {
        let debounce_window = self.subscriber.debounce_window_ms();

        if debounce_window == 0 {
            // No batching - handle immediately
            if let Err(e) = self.subscriber.handle_events(vec![event]).await {
                tracing::error!(
                    subscriber = %self.subscriber.name(),
                    error = %e,
                    "Subscriber failed to handle event",
                );
            }
        } else {
            // Add to batch
            let mut pending = self.pending_events.write().await;
            pending.push(event);
        }
    }
}

pub struct EventBus {
    sender: broadcast::Sender<Event>,
    subscribers: Arc<RwLock<Vec<SubscriberState>>>,
}

impl Default for EventBus {
    fn default() -> Self {
        Self::new()
    }
}

impl EventBus {
    pub fn new() -> Self {
        let (sender, _) = broadcast::channel(1000);

        Self {
            sender,
            subscribers: Arc::new(RwLock::new(Vec::new())),
        }
    }

    /// Register a subscriber
    pub async fn register_subscriber(&self, subscriber: Arc<dyn EventSubscriber>) {
        let state = SubscriberState::new(subscriber.clone());
        let mut subscribers = self.subscribers.write().await;
        subscribers.push(state);

        tracing::info!(
            subscriber = %subscriber.name(),
            debounce_ms = subscriber.debounce_window_ms(),
            "Registered event subscriber",
        );
    }

    /// Publish an entity event
    pub async fn publish_entity(&self, event: EntityEvent) -> Result<()> {
        self.publish(Event::Entity(Box::new(event))).await
    }

    /// Publish an auth event
    pub async fn publish_auth(&self, event: AuthEvent) -> Result<()> {
        self.publish(Event::Auth(event)).await
    }

    /// Publish an event to all subscribers
    async fn publish(&self, event: Event) -> Result<()> {
        match &event {
            Event::Entity(e) => {
                tracing::debug!(
                    operation = %e.operation,
                    entity_type = %e.entity_type,
                    entity_id = %e.entity_id,
                    "Publishing entity event",
                );
            }
            Event::Auth(e) => {
                tracing::debug!(
                    operation = ?e.operation,
                    user_id = ?e.user_id,
                    "Publishing auth event",
                );
            }
        }

        // Send to broadcast channel (non-blocking)
        let _ = self.sender.send(event.clone());

        // Notify subscribers
        let subscribers = self.subscribers.read().await;

        for state in subscribers.iter() {
            if state.subscriber.event_filter().matches(&event) {
                state.add_event(event.clone()).await;
            }
        }

        Ok(())
    }

    /// Get a receiver for raw event stream (useful for SSE)
    pub fn subscribe_channel(&self) -> broadcast::Receiver<Event> {
        self.sender.subscribe()
    }
}
