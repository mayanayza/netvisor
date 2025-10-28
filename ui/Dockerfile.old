FROM node:20-slim AS builder
WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --frozen-lockfile

# Copy source code
COPY . .

# Accept build args
ARG PUBLIC_SERVER_HOSTNAME=default
ARG PUBLIC_SERVER_PORT=60072

# Make available during build
ENV PUBLIC_SERVER_HOSTNAME=$PUBLIC_SERVER_HOSTNAME
ENV PUBLIC_SERVER_PORT=$PUBLIC_SERVER_PORT

# Build static site
RUN npm run build

# Production stage - output to /app/build for volume sharing
FROM alpine:latest AS runtime
WORKDIR /app

# Copy built static files
COPY --from=builder /app/build ./build

# Keep container running to share volume
CMD ["tail", "-f", "/dev/null"]