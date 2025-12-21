-- Create shares table for topology sharing and embedding
CREATE TABLE shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topology_id UUID NOT NULL REFERENCES topologies(id) ON DELETE CASCADE,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    expires_at TIMESTAMPTZ,
    password_hash TEXT,
    allowed_domains TEXT[],
    options JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shares_topology ON shares(topology_id);
CREATE INDEX idx_shares_network ON shares(network_id);
CREATE INDEX idx_shares_enabled ON shares(is_enabled) WHERE is_enabled = true;
