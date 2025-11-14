#[tokio::test]
pub async fn test_database_schema_backward_compatibility() {
    use crate::tests::SERVER_DB_FIXTURE;
    use crate::tests::setup_test_db;
    use std::path::Path;

    let db_path = Path::new(SERVER_DB_FIXTURE);

    if db_path.exists() {
        use std::process::Command;

        println!("Testing backward compatibility with database from latest release");

        let (pool, database_url, _container) = setup_test_db().await;

        // Parse connection details
        let url = url::Url::parse(&database_url).unwrap();
        let host = url.host_str().unwrap();
        let port = url.port().unwrap();
        let database = url.path().trim_start_matches('/');

        pool.close().await;

        // Use psql which understands all pg_dump output including meta-commands
        let output = Command::new("psql")
            .arg("-h")
            .arg(host)
            .arg("-p")
            .arg(port.to_string())
            .arg("-U")
            .arg("postgres")
            .arg("-d")
            .arg(database)
            .arg("-f")
            .arg(db_path)
            .env("PGPASSWORD", "password")
            .output()
            .expect("Failed to execute psql - ensure it's installed");

        assert!(
            output.status.success(),
            "Failed to restore database:\n{}",
            String::from_utf8_lossy(&output.stderr)
        );

        println!("Successfully restored database from fixture");

        let pool = sqlx::PgPool::connect(&database_url).await.unwrap();

        // Verify tables
        assert!(
            sqlx::query("SELECT * FROM hosts")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM services")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM subnets")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM groups")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM daemons")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM networks")
                .fetch_all(&pool)
                .await
                .is_ok()
        );
        assert!(
            sqlx::query("SELECT * FROM users")
                .fetch_all(&pool)
                .await
                .is_ok()
        );

        println!("Successfully read all tables from latest release database");

        sqlx::migrate!("./migrations")
            .run(&pool)
            .await
            .expect("Failed to apply current schema to old database");

        println!("Successfully applied current schema to old database");
    } else {
        panic!("No database fixture found at {}", SERVER_DB_FIXTURE);
    }
}
