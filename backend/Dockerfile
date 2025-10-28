# ============================================
# Stage 1: Build UI (SvelteKit static site)
# ============================================
FROM node:20-slim AS ui-builder

WORKDIR /app/ui

# Copy package files and install dependencies
COPY ui/package*.json ./
RUN npm ci --frozen-lockfile

# Copy UI source code
COPY ui/ ./

# Accept build-time configuration
ARG PUBLIC_SERVER_HOSTNAME=default
ARG PUBLIC_SERVER_PORT=60072

# Make available during build
ENV PUBLIC_SERVER_HOSTNAME=$PUBLIC_SERVER_HOSTNAME
ENV PUBLIC_SERVER_PORT=$PUBLIC_SERVER_PORT

# Build static UI assets
RUN npm run build

# Verify build output exists
RUN ls -la /app/ui/build && \
    test -f /app/ui/build/index.html || (echo "Build failed: no index.html found" && exit 1)

# ============================================
# Stage 2: Prepare Rust dependencies
# ============================================
FROM lukemathwalker/cargo-chef:latest-rust-1.90 AS chef
WORKDIR /app

FROM chef AS planner
COPY backend/ .
RUN cargo chef prepare --recipe-path recipe.json

# ============================================
# Stage 3: Build Rust server binary
# ============================================
FROM chef AS rust-builder

# Build dependencies first (cached layer)
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Build the server binary
COPY backend/ .
RUN cargo build --release --bin server

# Verify binary exists
RUN test -f /app/target/release/server || (echo "Server binary not found" && exit 1)

# ============================================
# Stage 4: Final runtime image
# ============================================
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy server binary from rust-builder stage
COPY --from=rust-builder /app/target/release/server /usr/local/bin/server
RUN chmod +x /usr/local/bin/server

# Copy UI static assets from ui-builder stage
COPY --from=ui-builder /app/ui/build ./static

# Verify UI files are present
RUN ls -la /app/static && \
    test -f /app/static/index.html || (echo "UI files not copied correctly" && exit 1)

EXPOSE 60072

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD curl -f http://localhost:60072/api/health || exit 1

# Run the server
CMD ["server"]