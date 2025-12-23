.PHONY: help build test clean format set-plan-community set-plan-starter set-plan-pro set-plan-team set-plan-business set-plan-enterprise

help:
	@echo "Scanopy Development Commands"
	@echo ""
	@echo "  make fresh-db       - Clean and set up a new database"
	@echo "  make setup-db       - Set up database"
	@echo "  make clean-db       - Clean up database"
	@echo "  make clean-daemon   - Remove daemon config file"
	@echo "  make dump-db        - Dump database to /scanopy"
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
	@echo ""
	@echo "Plan Management (sets plan for all organizations):"
	@echo "  make set-plan-community   - Set to Community (free)"
	@echo "  make set-plan-starter     - Set to Starter"
	@echo "  make set-plan-pro         - Set to Pro"
	@echo "  make set-plan-team        - Set to Team"
	@echo "  make set-plan-business    - Set to Business"
	@echo "  make set-plan-enterprise  - Set to Enterprise"

fresh-db:
	make clean-db
	make setup-db

setup-db:
	@echo "Setting up PostgreSQL..."
	@docker run -d \
		--name scanopy-postgres \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_DB=scanopy \
		-p 5432:5432 \
		postgres:17-alpine || echo "Already running"
	@sleep 3
	@echo "PostgreSQL ready at localhost:5432"

clean-db:
	docker stop scanopy-postgres || true
	docker rm scanopy-postgres || true

clean-daemon:
	rm -rf ~/Library/Application\ Support/com.scanopy.daemon

dump-db:
	docker exec -t scanopy-postgres pg_dump -U postgres -d scanopy > ~/dev/scanopy/scanopy.sql  

dev-server:
	@export DATABASE_URL="postgresql://postgres:password@localhost:5432/scanopy" && \
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

test:
	cd ui && npx vite-node scripts/export-daemon-field-defs.ts > ../backend/src/tests/daemon-config-frontend-fields.json
	make dev-down
	rm -rf ./data/daemon_config/*
	@export DATABASE_URL="postgresql://postgres:password@localhost:5432/scanopy_test" && \
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

# Plan management commands - set all organizations to a specific plan
set-plan-community:
	@echo "Setting all organizations to Community plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Community\", \"base_cents\": 0, \"rate\": \"Month\", \"trial_days\": 0, \"seat_cents\": null, \"network_cents\": null, \"included_seats\": null, \"included_networks\": null}'::jsonb"
	@echo "Done!"

set-plan-starter:
	@echo "Setting all organizations to Starter plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Starter\", \"base_cents\": 999, \"rate\": \"Month\", \"trial_days\": 7, \"seat_cents\": null, \"network_cents\": null, \"included_seats\": 1, \"included_networks\": 1}'::jsonb"
	@echo "Done!"

set-plan-pro:
	@echo "Setting all organizations to Pro plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Pro\", \"base_cents\": 1999, \"rate\": \"Month\", \"trial_days\": 7, \"seat_cents\": null, \"network_cents\": null, \"included_seats\": 1, \"included_networks\": 3}'::jsonb"
	@echo "Done!"

set-plan-team:
	@echo "Setting all organizations to Team plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Team\", \"base_cents\": 3999, \"rate\": \"Month\", \"trial_days\": 7, \"seat_cents\": 1000, \"network_cents\": 800, \"included_seats\": 5, \"included_networks\": 5}'::jsonb"
	@echo "Done!"

set-plan-business:
	@echo "Setting all organizations to Business plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Business\", \"base_cents\": 5999, \"rate\": \"Month\", \"trial_days\": 14, \"seat_cents\": 800, \"network_cents\": 500, \"included_seats\": 10, \"included_networks\": 25}'::jsonb"
	@echo "Done!"

set-plan-enterprise:
	@echo "Setting all organizations to Enterprise plan..."
	@docker exec -t scanopy-postgres psql -U postgres -d scanopy -c \
		"UPDATE organizations SET plan = '{\"type\": \"Enterprise\", \"base_cents\": 0, \"rate\": \"Month\", \"trial_days\": 0, \"seat_cents\": null, \"network_cents\": null, \"included_seats\": null, \"included_networks\": null}'::jsonb"
	@echo "Done!"
