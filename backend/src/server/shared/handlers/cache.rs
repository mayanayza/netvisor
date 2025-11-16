use moka::future::Cache;
use std::any::Any;
use std::sync::Arc;
use std::time::Duration;

pub struct AppCache {
    cache: Cache<String, Arc<dyn Any + Send + Sync>>,
}

impl AppCache {
    pub fn new() -> Self {
        Self {
            cache: Cache::builder().build(),
        }
    }

    /// Get a cached value with the expected type
    pub async fn get<T: Clone + Send + Sync + 'static>(&self, key: &str) -> Option<T> {
        let value = self.cache.get(key).await?;
        value.downcast_ref::<T>().cloned()
    }

    /// Set a cached value with a specific TTL in hours
    pub async fn set<T: Clone + Send + Sync + 'static>(&self, key: &str, value: T, ttl_hours: u64) {
        let ttl = Duration::from_secs(ttl_hours * 3600);
        self.cache
            .insert(
                key.to_string(),
                Arc::new(value) as Arc<dyn Any + Send + Sync>,
            )
            .await;

        // Schedule invalidation after TTL
        let cache = self.cache.clone();
        let key = key.to_string();
        tokio::spawn(async move {
            tokio::time::sleep(ttl).await;
            cache.invalidate(&key).await;
        });
    }

    /// Clear the entire cache
    pub async fn clear(&self) {
        self.cache.invalidate_all();
    }

    /// Remove a specific key
    pub async fn remove(&self, key: &str) {
        self.cache.invalidate(key).await;
    }

    /// Check if cache contains a key
    pub fn contains_key(&self, key: &str) -> bool {
        self.cache.contains_key(key)
    }
}

impl Clone for AppCache {
    fn clone(&self) -> Self {
        Self {
            cache: self.cache.clone(),
        }
    }
}

impl Default for AppCache {
    fn default() -> Self {
        Self::new()
    }
}
