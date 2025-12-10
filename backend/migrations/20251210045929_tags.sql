CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    color TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tags_organization ON tags(organization_id);
CREATE UNIQUE INDEX idx_tags_org_name ON tags(organization_id, name);

ALTER TABLE users ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE discovery ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE hosts ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE networks ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE subnets ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE groups ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE daemons ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE services ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE api_keys ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';
ALTER TABLE topologies ADD COLUMN tags UUID[] NOT NULL DEFAULT '{}';