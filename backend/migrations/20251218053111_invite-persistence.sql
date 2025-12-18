-- Add migration script here
CREATE TABLE IF NOT EXISTS invites (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    permissions TEXT NOT NULL,
    network_ids UUID[] NOT NULL,
    url TEXT NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    send_to TEXT
);

CREATE INDEX IF NOT EXISTS idx_invites_organization ON invites(organization_id);
CREATE INDEX IF NOT EXISTS idx_invites_expires_at ON invites(expires_at);
