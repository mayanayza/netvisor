use crate::server::{
    auth::middleware::auth::AuthenticatedEntity, config::AppState, shared::types::api::ApiError,
};
use axum::{
    extract::{FromRequestParts, Request, State},
    middleware::Next,
    response::{IntoResponse, Response},
};
use axum_client_ip::ClientIp;
use governor::{
    Quota, RateLimiter,
    clock::{Clock, DefaultClock},
    state::keyed::DashMapStateStore,
};
use std::{
    net::IpAddr,
    num::NonZeroU32,
    sync::{Arc, OnceLock},
    time::Duration,
};
use uuid::Uuid;

#[derive(Debug, Clone, Hash, Eq, PartialEq)]
pub enum RateLimitKey {
    User(Uuid),
    Ip(IpAddr),
}

type KeyedRateLimiter =
    Arc<RateLimiter<RateLimitKey, DashMapStateStore<RateLimitKey>, DefaultClock>>;

struct RateLimiters {
    user: KeyedRateLimiter,
    anonymous: KeyedRateLimiter,
}

static RATE_LIMITERS: OnceLock<RateLimiters> = OnceLock::new();

fn get_limiters() -> &'static RateLimiters {
    RATE_LIMITERS.get_or_init(|| {
        let limiters = RateLimiters {
            // Users: 5000 requests per hour
            user: Arc::new(RateLimiter::keyed(
                Quota::per_minute(NonZeroU32::new(300).unwrap())
                    .allow_burst(NonZeroU32::new(150).unwrap()),
            )),
            // Anonymous: 20 requests per minute
            anonymous: Arc::new(RateLimiter::keyed(
                Quota::per_minute(NonZeroU32::new(20).unwrap())
                    .allow_burst(NonZeroU32::new(5).unwrap()),
            )),
        };

        // Spawn cleanup task
        let user_limiter = Arc::clone(&limiters.user);
        let anonymous_limiter = Arc::clone(&limiters.anonymous);

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(60));
            loop {
                interval.tick().await;
                user_limiter.retain_recent();
                anonymous_limiter.retain_recent();
                tracing::debug!(
                    "Rate limiter cleanup: user keys={}, anonymous keys={}",
                    user_limiter.len(),
                    anonymous_limiter.len()
                );
            }
        });

        limiters
    })
}

#[derive(Debug, Clone)]
struct RateLimitInfo {
    limit: u32,
    remaining: u32,
    reset_in_secs: u64,
}

impl RateLimitInfo {
    fn apply_headers(&self, response: &mut Response) {
        let headers = response.headers_mut();
        if let Ok(v) = self.limit.to_string().parse() {
            headers.insert("X-RateLimit-Limit", v);
        }
        if let Ok(v) = self.remaining.to_string().parse() {
            headers.insert("X-RateLimit-Remaining", v);
        }
        if let Ok(v) = self.reset_in_secs.to_string().parse() {
            headers.insert("X-RateLimit-Reset", v);
        }
    }

    fn to_error_response(&self) -> Response {
        let mut response = ApiError::too_many_requests(format!(
            "Rate limit exceeded. Try again in {} seconds.",
            self.reset_in_secs
        ))
        .into_response();

        self.apply_headers(&mut response);

        if let Ok(v) = self.reset_in_secs.to_string().parse() {
            response.headers_mut().insert("Retry-After", v);
        }

        response
    }
}

fn check_user(user_id: Uuid) -> Result<RateLimitInfo, RateLimitInfo> {
    let limiters = get_limiters();
    let key = RateLimitKey::User(user_id);

    match limiters.user.check_key(&key) {
        Ok(_) => Ok(RateLimitInfo {
            limit: 100,
            remaining: 99,
            reset_in_secs: 60,
        }),
        Err(not_until) => {
            let wait_time = not_until
                .wait_time_from(DefaultClock::default().now())
                .as_secs();
            Err(RateLimitInfo {
                limit: 100,
                remaining: 0,
                reset_in_secs: wait_time,
            })
        }
    }
}

fn check_anonymous(ip: IpAddr) -> Result<RateLimitInfo, RateLimitInfo> {
    let limiters = get_limiters();
    let key = RateLimitKey::Ip(ip);

    match limiters.anonymous.check_key(&key) {
        Ok(_) => Ok(RateLimitInfo {
            limit: 20,
            remaining: 19,
            reset_in_secs: 60,
        }),
        Err(not_until) => {
            let wait_time = not_until
                .wait_time_from(DefaultClock::default().now())
                .as_secs();
            Err(RateLimitInfo {
                limit: 20,
                remaining: 0,
                reset_in_secs: wait_time,
            })
        }
    }
}

pub async fn rate_limit_middleware(
    State(state): State<Arc<AppState>>,
    ClientIp(ip): ClientIp,
    request: Request,
    next: Next,
) -> Result<Response, Response> {
    let path = request.uri().path();

    let exempt_paths = ["/api/billing/webhooks/", "/api/config", "/api/metadata"];

    // Exempt static file serving, billing webhooks, config and metadata
    if !path.starts_with("/api/") || exempt_paths.contains(&path) {
        return Ok(next.run(request).await);
    }

    let (mut parts, body) = request.into_parts();

    let entity = AuthenticatedEntity::from_request_parts(&mut parts, &state)
        .await
        .ok();

    // Daemons and System are exempt from rate limiting
    if let Some(ref e) = entity
        && matches!(
            e,
            AuthenticatedEntity::Daemon { .. } | AuthenticatedEntity::System
        )
    {
        let request = Request::from_parts(parts, body);
        return Ok(next.run(request).await);
    }

    let check_result = match entity {
        Some(AuthenticatedEntity::User { user_id, .. }) => check_user(user_id),
        _ => check_anonymous(ip),
    };

    match check_result {
        Ok(info) => {
            let request = Request::from_parts(parts, body);
            let mut response = next.run(request).await;
            info.apply_headers(&mut response);
            Ok(response)
        }
        Err(info) => Err(info.to_error_response()),
    }
}
