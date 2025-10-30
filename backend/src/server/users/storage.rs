use anyhow::Error;
use anyhow::Result;
use async_trait::async_trait;
use sqlx::{PgPool, Row};
use tracing::info;
use uuid::Uuid;

use crate::server::users::types::base::User;
use crate::server::users::types::base::UserBase;

#[async_trait]
pub trait UserStorage: Send + Sync {
    async fn create(&self, user: &User) -> Result<User>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<User>>;
    async fn get_all(&self) -> Result<Vec<User>>;
    async fn update(&self, group: &User) -> Result<()>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

pub struct PostgresUserStorage {
    pool: PgPool,
}

impl PostgresUserStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl UserStorage for PostgresUserStorage {
    async fn create(&self, user: &User) -> Result<User> {
        sqlx::query(
            r#"
            INSERT INTO users (
                id, name, created_at, updated_at, username, password_hash
            ) VALUES ($1, $2, $3, $4, $5, $6)
            "#,
        )
        .bind(user.id)
        .bind(&user.base.name)
        .bind(chrono::Utc::now())
        .bind(chrono::Utc::now())
        .bind(&user.base.username)
        .bind(&user.base.password_hash)
        .execute(&self.pool)
        .await?;

        Ok(user.clone())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM users WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_user(row)?)),
            None => Ok(None),
        }
    }

    async fn get_all(&self) -> Result<Vec<User>> {
        let rows = sqlx::query("SELECT * FROM users ORDER BY created_at DESC")
            .fetch_all(&self.pool)
            .await
            .map_err(|e| {
                info!("SQLx error in get_all: {:?}", e);
                e
            })?;

        let mut users = Vec::new();
        for row in rows {
            users.push(row_to_user(row)?);
        }

        Ok(users)
    }

    async fn update(&self, user: &User) -> Result<()> {
        sqlx::query(
            r#"
            UPDATE users SET 
                name = $2, updated_at = $3, username = $4, password_hash = $5
            WHERE id = $1
            "#,
        )
        .bind(user.id)
        .bind(&user.base.name)
        .bind(chrono::Utc::now())
        .bind(&user.base.username)
        .bind(&user.base.password_hash)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM users WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_user(row: sqlx::postgres::PgRow) -> Result<User, Error> {
    Ok(User {
        id: row.get("id"),
        created_at: row.get("created_at"),
        updated_at: row.get("updated_at"),
        base: UserBase {
            name: row.get("name"),
            username: row.get("username"),
            password_hash: row.get("password_hash"),
        },
    })
}
