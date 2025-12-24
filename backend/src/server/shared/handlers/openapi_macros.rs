//! Macros for generating OpenAPI-annotated CRUD handlers
//!
//! These macros generate thin wrapper handlers with `#[utoipa::path]` annotations
//! that delegate to the generic CRUD handlers. Use them for operations that use
//! the standard generic handlers - write custom handlers for operations that need
//! custom logic.
//!
//! Query param documentation is automatically derived from the filter query type's
//! `IntoParams` implementation. Add doc comments to fields in query structs to
//! customize the OpenAPI parameter descriptions.
//!
//! # Usage
//! ```ignore
//! // In a module block inside handlers.rs:
//! mod generated {
//!     use super::*;
//!     // For entities with network filtering:
//!     crate::crud_get_all_handler!(Daemon, "daemons", "daemon");
//!     // Other CRUD operations:
//!     crate::crud_get_by_id_handler!(Port, "ports", "port");
//!     crate::crud_create_handler!(Port, "ports", "port");
//!     crate::crud_update_handler!(Port, "ports", "port");
//!     crate::crud_delete_handler!(Port, "ports", "port");
//!     crate::crud_bulk_delete_handler!(Port, "ports");
//! }
//!
//! // Then in create_router():
//! OpenApiRouter::new()
//!     .routes(routes!(generated::get_all, generated::create))
//!     .routes(routes!(generated::get_by_id, generated::update, generated::delete))
//!     .routes(routes!(generated::bulk_delete))
//! ```

/// Generates an OpenAPI-annotated get-by-id handler that delegates to `get_by_id_handler::<T>`
#[macro_export]
macro_rules! crud_get_by_id_handler {
    ($entity:ty, $response:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            get,
            path = "/{id}",
            tag = $tag,
            operation_id = concat!("get_", $singular, "_by_id"),
            summary = concat!("Get ", $singular, " by ID"),
            params(("id" = uuid::Uuid, Path, description = concat!(stringify!($entity), " ID"))),
            responses(
                (status = 200, description = concat!(stringify!($entity), " found"), body = $response),
                (status = 404, description = concat!(stringify!($entity), " not found")),
            ),
            security(("session" = []))
        )]
        pub async fn get_by_id(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            path: axum::extract::Path<uuid::Uuid>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$response>>,
        > {
            $crate::server::shared::handlers::traits::get_by_id_handler::<$entity>(state, user, path)
                .await
        }
    };
    // Backwards-compatible version where response = entity
    ($entity:ty, $tag:expr, $singular:expr) => {
        $crate::crud_get_by_id_handler!($entity, $entity, $tag, $singular);
    };
}

/// Generates an OpenAPI-annotated create handler that delegates to `create_handler::<T>`
#[macro_export]
macro_rules! crud_create_handler {
    ($entity:ty, $create_request:ty, $response:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            post,
            path = "",
            tag = $tag,
            operation_id = concat!("create_", $singular),
            summary = concat!("Create new ", $singular),
            request_body = $create_request,
            responses(
                (status = 200, description = concat!(stringify!($entity), " created"), body = $response),
                (status = 400, description = "Invalid request"),
            ),
            security(("session" = []))
        )]
        pub async fn create(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            body: axum::response::Json<$create_request>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$response>>,
        > {
            $crate::server::shared::handlers::traits::create_handler::<$entity>(state, user, body)
                .await
        }
    };
    // Backwards-compatible version where request = response = entity
    ($entity:ty, $tag:expr, $singular:expr) => {
        $crate::crud_create_handler!($entity, $entity, $entity, $tag, $singular);
    };
}

/// Generates an OpenAPI-annotated update handler that delegates to `update_handler::<T>`
#[macro_export]
macro_rules! crud_update_handler {
    ($entity:ty, $update_request:ty, $response:ty, $tag:expr, $singular:expr) => {
        #[utoipa::path(
            put,
            path = "/{id}",
            tag = $tag,
            operation_id = concat!("update_", $singular),
            summary = concat!("Update ", $singular),
            params(("id" = uuid::Uuid, Path, description = concat!(stringify!($entity), " ID"))),
            request_body = $update_request,
            responses(
                (status = 200, description = concat!(stringify!($entity), " updated"), body = $response),
                (status = 404, description = concat!(stringify!($entity), " not found")),
            ),
            security(("session" = []))
        )]
        pub async fn update(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::permissions::RequireMember,
            path: axum::extract::Path<uuid::Uuid>,
            body: axum::response::Json<$update_request>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<$response>>,
        > {
            $crate::server::shared::handlers::traits::update_handler::<$entity>(
                state, user, path, body,
            )
            .await
        }
    };
    // Backwards-compatible version where request = response = entity
    ($entity:ty, $tag:expr, $singular:expr) => {
        $crate::crud_update_handler!($entity, $entity, $entity, $tag, $singular);
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
            operation_id = concat!("delete_", $singular),
            summary = concat!("Delete ", $singular),
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
            operation_id = concat!("bulk_delete_", $tag),
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

/// Generates an OpenAPI-annotated get_all handler with query params derived from the filter query type.
/// The filter query type must derive `IntoParams` for utoipa to extract the param documentation.
///
/// # Example
/// ```ignore
/// // For network-filtered entities:
/// crud_get_all_handler!(Daemon, "daemons", "daemon");
/// // With custom response type:
/// crud_get_all_handler!(Group, GroupResponse, "groups", "group");
/// ```
#[macro_export]
macro_rules! crud_get_all_handler {
    ($entity:ty, $response:ty, $tag:expr, $singular:expr) => {
        // Type alias to resolve the associated type in a way utoipa can process
        type __GetAllFilterQuery = <$entity as $crate::server::shared::handlers::traits::CrudHandlers>::FilterQuery;

        #[utoipa::path(
            get,
            path = "",
            tag = $tag,
            operation_id = concat!("list_", $tag),
            summary = concat!("List all ", $tag),
            params(__GetAllFilterQuery),
            responses(
                (status = 200, description = concat!("List of ", $tag), body = Vec<$response>),
            ),
            security(("session" = []))
        )]
        pub async fn get_all(
            state: axum::extract::State<std::sync::Arc<$crate::server::config::AppState>>,
            user: $crate::server::auth::middleware::auth::AuthenticatedUser,
            query: axum::extract::Query<__GetAllFilterQuery>,
        ) -> $crate::server::shared::types::api::ApiResult<
            axum::response::Json<$crate::server::shared::types::api::ApiResponse<Vec<$response>>>,
        > {
            $crate::server::shared::handlers::traits::get_all_handler::<$entity>(state, user, query)
                .await
        }
    };
    // Backwards-compatible version where response = entity
    ($entity:ty, $tag:expr, $singular:expr) => {
        $crate::crud_get_all_handler!($entity, $entity, $tag, $singular);
    };
}