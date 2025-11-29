.PHONY: help build test clean format

help:
	@echo "NetVisor Development Commands"
	@echo ""
	@echo "  make fresh-db       - Clean and set up a new database"
	@echo "  make setup-db       - Set up database"
	@echo "  make clean-db       - Clean up database"
	@echo "  make clean-daemon   - Remove daemon config file"
	@echo "  make dump-db        - Dump database to /netvisor"
	@echo "  make dev-server     - Start server dev environment"
	@echo "  make dev-ui         - Start ui"
	@echo "  make dev-daemon     - Start daemon dev environment"
	@echo "  make dev-container  - Start containerized development environment using docker-compose.dev.yml (server + ui + daemon)"
	@echo "  make dev-container-rebuild  - Rebuild and start containerized dev environment"
	@echo "  make dev-container-rebuild-clean  - Rebuild, clean, and start containerized dev environment"
	@echo "  make dev-down       - Stop development containers"
	@echo "  make build          - Build production Docker images (server + daemon)"
	@echo "  make test           - Run all tests"
	@echo "  make lint           - Run all linters"
	@echo "  make format         - Format all code"
	@echo "  make clean          - Clean build artifacts and containers"
	@echo "  make install-dev-mac    - Install development dependencies on macOS"
	@echo "  make install-dev-linux  - Install development dependencies on Linux"

fresh-db:
	make clean-db
	make setup-db

setup-db:
	@echo "Setting up PostgreSQL..."
	@docker run -d \
		--name netvisor-postgres \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_DB=netvisor \
		-p 5432:5432 \
		postgres:17-alpine || echo "Already running"
	@sleep 3
	@echo "PostgreSQL ready at localhost:5432"

clean-db:
	docker stop netvisor-postgres || true
	docker rm netvisor-postgres || true

clean-daemon:
	rm -rf ~/Library/Application\ Support/com.netvisor.daemon

dump-db:
	docker exec -t netvisor-postgres pg_dump -U postgres -d netvisor > ~/dev/netvisor/netvisor.sql  

dev-server:
	@export DATABASE_URL="postgresql://postgres:password@localhost:5432/netvisor" && \
	cd backend && cargo run --bin server -- --log-level debug --public-url http://localhost:60072

dev-daemon:
	cd backend && cargo run --bin daemon -- --server-url http://127.0.0.1:60072 --log-level debug

dev-ui:
	cd ui && npm run dev

dev-container:
	docker compose -f docker-compose.dev.yml up

dev-container-rebuild:
	docker compose -f docker-compose.dev.yml up --build --force-recreate

dev-container-rebuild-clean:
	docker compose -f docker-compose.dev.yml build --no-cache
	docker compose -f docker-compose.dev.yml up

dev-down:
	docker compose -f docker-compose.dev.yml down --volumes --rmi local

build:
	@echo "Building Server + UI Docker image..."
	docker build -f backend/Dockerfile -t mayanayza/netvisor-server:latest .
	@echo "✓ Server image built: mayanayza/netvisor-server:latest"
	@echo ""
	@echo "Building Daemon Docker image..."
	docker build -f backend/Dockerfile.daemon -t mayanayza/netvisor-daemon:latest ./backend
	@echo "✓ Daemon image built: mayanayza/netvisor-daemon:latest"

test:
	make dev-down
	rm -rf ./data/daemon_config/*
	@export DATABASE_URL="postgresql://postgres:password@localhost:5432/netvisor_test" && \
	cd backend && cargo test -- --nocapture --test-threads=1

format:
	@echo "Formatting Server..."
	cd backend && cargo fmt
	@echo "Formatting UI..."
	cd ui && npm run format
	@echo "All code formatted!"

lint:
	@echo "Linting Server..."
	cd backend && cargo fmt -- --check && cargo clippy --bin server -- -D warnings
	@echo "Linting Daemon..."
	cd backend && cargo clippy --bin daemon -- -D warnings
	@echo "Linting UI..."
	cd ui && npm run lint && npm run format -- --check && npm run check

stripe-webhook:
	stripe listen --forward-to http://localhost:60072/api/billing/webhooks

clean:
	make clean-db
	docker compose down -v
	cd backend && cargo clean
	cd ui && rm -rf node_modules dist build .svelte-kit

install-dev-mac:
	@echo "Installing Rust toolchain..."
	rustup install stable
	rustup component add rustfmt clippy
	@echo "Installing Node.js dependencies..."
	cd ui && npm install
	@echo "Installing pre-commit hooks..."
	@command -v pre-commit >/dev/null 2>&1 || { \
		echo "Installing pre-commit via pip..."; \
		pip3 install pre-commit --break-system-packages || pip3 install pre-commit; \
	}
	pre-commit install
	pre-commit install --hook-type pre-push
	@echo "Development dependencies installed!"
	@echo "Note: Run 'source ~/.zshrc' to update your PATH, or restart your terminal"

install-dev-linux:
	@echo "Installing Rust toolchain..."
	rustup install stable
	rustup component add rustfmt clippy
	@echo "Installing Node.js dependencies..."
	cd ui && npm install
	@echo "Installing pre-commit hooks..."
	@command -v pre-commit >/dev/null 2>&1 || { \
		echo "Installing pre-commit via pip..."; \
		pip3 install pre-commit --break-system-packages || pip3 install pre-commit; \
	}
	pre-commit install
	pre-commit install --hook-type pre-push
	@echo ""
	@echo "Development dependencies installed!"
