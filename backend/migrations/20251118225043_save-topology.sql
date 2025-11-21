CREATE TABLE topologies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    edges JSONB NOT NULL,
    nodes JSONB NOT NULL,
    options JSONB NOT NULL,
    hosts JSONB NOT NULL,
    subnets JSONB NOT NULL,
    services JSONB NOT NULL,
    groups JSONB NOT NULL,
    is_stale BOOLEAN,
    last_refreshed TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_locked BOOLEAN,
    locked_at TIMESTAMPTZ,
    locked_by UUID,
    removed_hosts UUID[],
    removed_services UUID[],
    removed_subnets UUID[],
    removed_groups UUID[],
    parent_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_topologies_network ON topologies(network_id);

-- Migration to change hosts.services from JSONB to UUID[]
-- Converts JSONB array to UUID array, handles NULL and non-array cases

ALTER TABLE hosts 
    ALTER COLUMN services TYPE UUID[] 
    USING CASE 
        WHEN services IS NULL THEN NULL
        ELSE translate(services::text, '[]"', '{}')::UUID[]
    END;