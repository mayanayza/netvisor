use crate::server::shared::storage::{
    filter::EntityFilter,
    traits::{SqlValue, StorableEntity, Storage},
};
use async_trait::async_trait;
use chrono::Utc;
use ipnetwork::IpNetwork;
use sqlx::{PgPool, Postgres, postgres::PgArguments};
use std::{fmt::Display, marker::PhantomData};
use uuid::Uuid;

pub struct GenericPostgresStorage<T: StorableEntity> {
    pool: PgPool,
    _phantom: PhantomData<T>,
}

impl<T: StorableEntity> GenericPostgresStorage<T>
where
    T: Display,
{
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            _phantom: PhantomData,
        }
    }

    /// Generate INSERT query dynamically
    fn build_insert_query(columns: &[&str]) -> String {
        let placeholders: Vec<String> = (1..=columns.len()).map(|i| format!("${}", i)).collect();

        format!(
            "INSERT INTO {} ({}) VALUES ({})",
            T::table_name(),
            columns.join(", "),
            placeholders.join(", ")
        )
    }

    /// Generate UPDATE query dynamically
    fn build_update_query(columns: &[&str]) -> String {
        let set_clauses: Vec<String> = columns
            .iter()
            .enumerate()
            .skip(1) // Skip 'id' column
            .map(|(i, col)| format!("{} = ${}", col, i + 1))
            .collect();

        format!(
            "UPDATE {} SET {} WHERE id = $1",
            T::table_name(),
            set_clauses.join(", ")
        )
    }

    /// Bind SqlValue to query
    fn bind_value<'q>(
        query: sqlx::query::Query<'q, Postgres, PgArguments>,
        value: &'q SqlValue,
    ) -> Result<sqlx::query::Query<'q, Postgres, PgArguments>, anyhow::Error> {
        let value = match value {
            SqlValue::Uuid(v) => query.bind(v),
            SqlValue::OptionalUuid(v) => query.bind(v),
            SqlValue::String(v) => query.bind(v),
            SqlValue::U16(v) => query.bind(Into::<i32>::into(*v)),
            SqlValue::I32(v) => query.bind(v),
            SqlValue::Bool(v) => query.bind(v),
            SqlValue::Timestamp(v) => query.bind(v),
            SqlValue::OptionTimestamp(v) => query.bind(v),
            SqlValue::UuidArray(v) => query.bind(v.clone()),
            SqlValue::OptionalString(v) => query.bind(v),
            SqlValue::EntitySource(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::IpCidr(v) => query.bind(serde_json::to_string(v)?),
            SqlValue::ServiceDefinition(v) => query.bind(serde_json::to_string(v)?),
            SqlValue::OptionalServiceVirtualization(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Interfaces(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Ports(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::OptionalHostVirtualization(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::DaemonCapabilities(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::IpAddr(v) => {
                // Convert IpAddr to IpNetwork for proper INET binding
                let network = IpNetwork::from(*v);
                query.bind(network)
            }
            SqlValue::RunType(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::DiscoveryType(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Email(v) => query.bind(v.as_str()),
            SqlValue::UserOrgPermissions(v) => query.bind(v.as_str()),
            SqlValue::DaemonMode(v) => query.bind(serde_json::to_string(v)?),
            SqlValue::OptionBillingPlan(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::OptionBillingPlanStatus(v) => query.bind(serde_json::to_string(v)?),
            SqlValue::EdgeStyle(v) => query.bind(v.to_string()),
            SqlValue::Nodes(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Edges(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::TopologyOptions(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Hosts(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Subnets(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Services(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::Groups(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::TelemetryOperation(v) => query.bind(serde_json::to_value(v)?),
            SqlValue::StringArray(v) => query.bind(v.clone()),
            SqlValue::OptionalStringArray(v) => query.bind(v.clone()),
            SqlValue::JsonValue(v) => query.bind(v.clone()),
            SqlValue::OptionalMacAddress(v) => {
                // sqlx mac_address feature supports MacAddress directly
                query.bind(*v)
            }
        };

        Ok(value)
    }
}

#[async_trait]
impl<T: StorableEntity> Storage<T> for GenericPostgresStorage<T>
where
    T: Display,
{
    async fn create(&self, entity: &T) -> Result<T, anyhow::Error> {
        let (columns, values) = entity.to_params()?;
        let query_str = Self::build_insert_query(&columns);

        let mut query = sqlx::query(&query_str);
        for value in &values {
            query = Self::bind_value(query, value)?;
        }

        query.execute(&self.pool).await?;
        tracing::trace!("Created {}: {}", T::table_name(), entity);
        Ok(entity.clone())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<T>, anyhow::Error> {
        let id_filter = EntityFilter::unfiltered().entity_id(id);
        self.get_one(id_filter).await
    }

    async fn get_one(&self, filter: EntityFilter) -> Result<Option<T>, anyhow::Error> {
        let query_str = format!(
            "SELECT * FROM {} {}",
            T::table_name(),
            filter.to_where_clause()
        );

        let mut query = sqlx::query(&query_str);

        for value in filter.values() {
            query = Self::bind_value(query, value)?;
        }

        let row = query.fetch_optional(&self.pool).await?;

        let result = row.map(|r| T::from_row(&r)).transpose()?;

        Ok(result)
    }

    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<T>, anyhow::Error> {
        self.get_all_ordered(filter, "created_at ASC").await
    }

    async fn get_all_ordered(
        &self,
        filter: EntityFilter,
        order_by: &str,
    ) -> Result<Vec<T>, anyhow::Error> {
        let query_str = format!(
            "SELECT * FROM {} {} ORDER BY {}",
            T::table_name(),
            filter.to_where_clause(),
            order_by
        );

        let mut query = sqlx::query(&query_str);
        for value in filter.values() {
            query = Self::bind_value(query, value)?;
        }

        let rows = query.fetch_all(&self.pool).await?;
        rows.into_iter().map(|r| T::from_row(&r)).collect()
    }

    async fn update(&self, entity: &mut T) -> Result<T, anyhow::Error> {
        entity.set_updated_at(Utc::now());

        let (columns, values) = entity.to_params()?;
        let query_str = Self::build_update_query(&columns);

        let mut query = sqlx::query(&query_str);
        for value in &values {
            query = Self::bind_value(query, value)?;
        }

        tracing::trace!("Updated {}", entity);

        query.execute(&self.pool).await?;
        Ok(entity.clone())
    }

    async fn delete(&self, id: &Uuid) -> Result<(), anyhow::Error> {
        let query_str = format!("DELETE FROM {} WHERE id = $1", T::table_name());

        sqlx::query(&query_str).bind(id).execute(&self.pool).await?;

        tracing::trace!("Deleted {} with id: {}", T::table_name(), id);

        Ok(())
    }

    async fn delete_many(&self, ids: &[Uuid]) -> Result<usize, anyhow::Error> {
        if ids.is_empty() {
            return Ok(0);
        }

        let query_str = format!("DELETE FROM {} WHERE id = ANY($1)", T::table_name());

        let result = sqlx::query(&query_str)
            .bind(ids)
            .execute(&self.pool)
            .await?;

        let deleted_count = result.rows_affected() as usize;

        tracing::trace!(
            "Bulk deleted {} {}s (requested: {}, deleted: {})",
            deleted_count,
            T::table_name(),
            ids.len(),
            deleted_count
        );

        Ok(deleted_count)
    }

    async fn delete_by_filter(&self, filter: EntityFilter) -> Result<usize, anyhow::Error> {
        let query_str = format!(
            "DELETE FROM {} {}",
            T::table_name(),
            filter.to_where_clause()
        );

        let mut query = sqlx::query(&query_str);
        for value in filter.values() {
            query = Self::bind_value(query, value)?;
        }

        let result = query.execute(&self.pool).await?;
        let deleted_count = result.rows_affected() as usize;

        tracing::trace!("Deleted {} {}s by filter", deleted_count, T::table_name());

        Ok(deleted_count)
    }
}
