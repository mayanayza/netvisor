FROM lukemathwalker/cargo-chef:latest-rust-1.90 AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies in release mode with size optimizations
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
# Build server in release mode for production
RUN cargo build --release --bin server

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy release binary
COPY --from=builder /app/target/release/server /usr/local/bin/server
RUN chmod +x /usr/local/bin/server

EXPOSE 60072

# Add health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD curl -f http://localhost:60072/api/health || exit 1

CMD ["sh", "-c", "server"]