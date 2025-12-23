//! Macros for generating OpenAPI-annotated CRUD handlers
//!
//! These macros generate thin wrapper handlers with `#[utoipa::path]` annotations
//! that delegate to the generic CRUD handlers. Use them for operations that use
//! the standard generic handlers - write custom handlers for operations that need
//! custom logic.
//!
//! # Usage
//! ```ignore
//! // In a module block inside handlers.rs:
//! mod generated {
//!     use super::*;
//!     crate::crud_get_by_id_handler!(Group, "groups", "group");
//!     crate::crud_update_handler!(Group, "groups", "group");
//!     crate::crud_delete_handler!(Group, "groups", "group");
//!     crate::crud_bulk_delete_handler!(Group, "groups");  // uses tag for plural
//! }
//!
//! // Then in create_router():
//! OpenApiRouter::new()
//!     .routes(routes!(get_all_groups, create_group))  // custom handlers
//!     .routes(routes!(generated::get_by_id, generated::update, generated::delete))
//!     .routes(routes!(generated::bulk_delete))
//! ```

/// Generates an OpenAPI-annotated get-by-id handler that delegates to `get_by_id_handler::<T>`
#[macro_export]
macro_rules! crud_get_by_id_handler {
    ($entity:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            get,
            path = "/{id}",
            tag = $tag,
            summary = concat!("Get a ", $singular, " by ID"),
            params(("id" = uuid::Uuid, Path, description = concat!(stringify!($entity), " ID"))),
            responses(
                (status = 200, description = concat!(stringify!($entity), " found"), body = $entity),
                (status = 404, description = concat!(stringify!($entity), " not found")),
            ),
            security(("session" = []))
        )]
        pub async fn get_by_id(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            path: axum::extract::Path<uuid::Uuid>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$entity>>,
        > {
            $crate::server::shared::handlers::traits::get_by_id_handler::<$entity>(state, user, path)
                .await
        }
    };
}

/// Generates an OpenAPI-annotated create handler that delegates to `create_handler::<T>`
#[macro_export]
macro_rules! crud_create_handler {
    ($entity:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            post,
            path = "",
            tag = $tag,
            summary = concat!("Create a new ", $singular),
            request_body = $entity,
            responses(
                (status = 200, description = concat!(stringify!($entity), " created"), body = $entity),
                (status = 400, description = "Invalid request"),
            ),
            security(("session" = []))
        )]
        pub async fn create(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            body: axum::response::Json<$entity>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$entity>>,
        > {
            $crate::server::shared::handlers::traits::create_handler::<$entity>(state, user, body)
                .await
        }
    };
}

/// Generates an OpenAPI-annotated update handler that delegates to `update_handler::<T>`
#[macro_export]
macro_rules! crud_update_handler {
    ($entity:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            put,
            path = "/{id}",
            tag = $tag,
            summary = concat!("Update a ", $singular),
            params(("id" = uuid::Uuid, Path, description = concat!(stringify!($entity), " ID"))),
            request_body = $entity,
            responses(
                (status = 200, description = concat!(stringify!($entity), " updated"), body = $entity),
                (status = 404, description = concat!(stringify!($entity), " not found")),
            ),
            security(("session" = []))
        )]
        pub async fn update(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            path: axum::extract::Path<uuid::Uuid>,
            body: axum::response::Json<$entity>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$entity>>,
        > {
            $crate::server::shared::handlers::traits::update_handler::<$entity>(
                state, user, path, body,
            )
            .await
        }
    };
}

/// Generates an OpenAPI-annotated delete handler that delegates to `delete_handler::<T>`
#[macro_export]
macro_rules! crud_delete_handler {
    ($entity:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            delete,
            path = "/{id}",
            tag = $tag,
            summary = concat!("Delete a ", $singular),
            params(("id" = uuid::Uuid, Path, description = concat!(stringify!($entity), " ID"))),
            responses(
                (status = 200, description = concat!(stringify!($entity), " deleted")),
                (status = 404, description = concat!(stringify!($entity), " not found")),
            ),
            security(("session" = []))
        )]
        pub async fn delete(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            path: axum::extract::Path<uuid::Uuid>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<()>>,
        > {
            $crate::server::shared::handlers::traits::delete_handler::<$entity>(state, user, path)
                .await
        }
    };
}

/// Generates an OpenAPI-annotated bulk delete handler that delegates to `bulk_delete_handler::<T>`
#[macro_export]
macro_rules! crud_bulk_delete_handler {
    ($entity:ty, $tag:expr) => {
        #[utoipa::path(
            post,
            path = "/bulk-delete",
            tag = $tag,
            summary = concat!("Bulk delete ", $tag),
            request_body(content = Vec<uuid::Uuid>, description = concat!("Array of ", $tag, " IDs to delete")),
            responses(
                (status = 200, description = concat!(stringify!($entity), "s deleted"), body = $crate::server::shared::handlers::traits::BulkDeleteResponse),
            ),
            security(("session" = []))
        )]
        pub async fn bulk_delete(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            body: axum::response::Json<Vec<uuid::Uuid>>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<
                $crate::server::shared::types::api::ApiResponse<
                    $crate::server::shared::handlers::traits::BulkDeleteResponse,
                >,
            >,
        > {
            $crate::server::shared::handlers::traits::bulk_delete_handler::<$entity>(
                state, user, body,
            )
            .await
        }
    };
}
