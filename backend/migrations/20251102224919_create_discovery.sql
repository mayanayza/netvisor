ALTER TABLE daemons ADD COLUMN capabilities JSONB DEFAULT '{}';

CREATE TABLE IF NOT EXISTS discovery (
    id UUID PRIMARY KEY,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    daemon_id UUID NOT NULL REFERENCES daemons(id) ON DELETE CASCADE,
    run_type JSONB NOT NULL,
    discovery_type JSONB NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_discovery_daemon ON discovery(daemon_id);
CREATE INDEX IF NOT EXISTS idx_discovery_network ON discovery(network_id);